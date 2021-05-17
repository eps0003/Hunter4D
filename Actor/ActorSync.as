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
                bs.write_netid(player.getNetworkID());
                this.SendCommand(this.getCommandID("spawn actor"), bs, true);
            }
        }
    }
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
    // Tell clients to spawn actor
    CBitStream bs;
    bs.write_netid(player.getNetworkID());
    this.SendCommand(this.getCommandID("spawn actor"), bs, true);

    // Sync all actors
    Actor@[] actors = Actor::getActors();

    for (uint i = 0; i < actors.size(); i++)
    {
        Actor@ actor = actors[i];

        CBitStream bs;
        actor.SerializeInit(bs);
        this.SendCommand(this.getCommandID("init actor"), bs, player);
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

    // Update actors
    Actor@[] actors = Actor::getActors();
    for (uint i = 0; i < actors.size(); i++)
    {
        actors[i].Update();
    }
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
    if (isClient() && cmd == this.getCommandID("spawn actor"))
    {
        CPlayer@ player = getPlayerByNetworkId(params.read_netid());
        if (player !is null)
        {
            SpawnActor(this, player);
        }
    }
    else if (cmd == this.getCommandID("init actor"))
    {
        Actor actor(params);

        // Don't set my own actor. Already did it on spawn
        if (actor.player.isMyPlayer()) return;

        Actor::SetActor(actor.player, actor);
    }
    else if (cmd == this.getCommandID("sync actor"))
    {
        // Deserialize actor
        Actor newActor(params);

        // Don't update my own actor
        if (newActor.player.isMyPlayer()) return;

        // Update actor
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
