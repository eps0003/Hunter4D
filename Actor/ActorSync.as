#include "Actor.as"

// Server tells client to spawn actor
// Client spawns actor and send init command to server and clients
// Both server and client inits actor

// Client syncs actor each tick to server only
// If actor exists on server, update and sync to clients
// Else, ignore

void onInit(CRules@ this)
{
    this.addCommandID("init actor");
    this.addCommandID("sync actor");
    this.addCommandID("spawn actor");

    if (isServer())
    {
        if (isClient())
        {
            // Localhost
            for (uint i = 0; i < getPlayerCount(); i++)
            {
                CPlayer@ player = getPlayer(i);
                SpawnActor(this, player);
            }
        }
        else
        {
            // Server
            for (uint i = 0; i < getPlayerCount(); i++)
            {
                CPlayer@ player = getPlayer(i);

                CBitStream bs;
                this.SendCommand(this.getCommandID("spawn actor"), bs, true);
            }
        }
    }
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
    CBitStream bs;
    this.SendCommand(this.getCommandID("spawn actor"), bs, true);

    for (uint i = 0; i < getPlayerCount(); i++)
    {
        CPlayer@ player = getPlayer(i);
        Actor@ actor = Actor::getActor(player);

        if (actor !is null)
        {
            CBitStream bs;
            actor.SerializeInit(bs);
            this.SendCommand(this.getCommandID("init actor"), bs, true);
        }
    }
}

void onTick(CRules@ this)
{
    if (!isServer())
    {
        // Sync my actor
        Actor@ actor = Actor::getMyActor();
        if (actor !is null)
        {
            CBitStream bs;
            actor.SerializeTick(bs);
            this.SendCommand(this.getCommandID("sync actor"), bs, true);
        }
    }
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
    if (isClient() && cmd == this.getCommandID("spawn actor"))
    {
        CPlayer@ player = getLocalPlayer();
        SpawnActor(this, player);
    }
    else if (cmd == this.getCommandID("init actor"))
    {
        Actor actor(params);
        Actor::SetActor(actor.player, actor);
    }
    else if (cmd == this.getCommandID("sync actor"))
    {
        Actor newActor(params);

        // Don't update my own actor because the client is in control
        if (newActor.player.isMyPlayer()) return;

        Actor@ oldActor = Actor::getActor(newActor.player);

        if (oldActor !is null)
        {
            oldActor = newActor;
        }
    }
}

void SpawnActor(CRules@ this, CPlayer@ player)
{
    // Spawn actor
    Actor actor(player, Vec3f());
    Actor::SetActor(player, actor);

    // Sync if not localhost
    if (!isServer())
    {
        CBitStream bs;
        actor.SerializeInit(bs);
        this.SendCommand(this.getCommandID("init actor"), bs, true);
    }
}
