#include "Actor.as"

Vec3f SPAWN_POSITION = Vec3f(-1, 0, -1);

void onInit(CRules@ this)
{
	this.addCommandID("init actor");
	this.addCommandID("sync actor");

	if (isServer())
	{
		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player !is null)
			{
				Actor actor(player, SPAWN_POSITION);
				Actor::SetActor(player, actor);
			}
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	Actor actor(player, SPAWN_POSITION);
	Actor::SetActor(player, actor);

	// Sync all actors
	Actor@[] actors = Actor::getActors();

	for (uint i = 0; i < actors.size(); i++)
	{
		Actor@ actor = actors[i];
		if (actor.player is player) continue;

		CBitStream bs;
		actor.SerializeInit(bs);
		this.SendCommand(this.getCommandID("init actor"), bs, player);
	}
}

void onTick(CRules@ this)
{
	// Update actors
	Actor@[] actors = Actor::getActors();
	for (uint i = 0; i < actors.size(); i++)
	{
		actors[i].Update();
	}

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
	if (!isServer() && cmd == this.getCommandID("init actor"))
	{
		Actor actor;
		actor.DeserializeInit(params);
		Actor::SetActor(actor.player, actor);
	}
	else if (cmd == this.getCommandID("sync actor"))
	{
		// Deserialize actor
		Actor newActor;
		newActor.DeserializeTick(params);

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
