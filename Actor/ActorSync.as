#include "Actor.as"

Vec3f SPAWN_POSITION = Vec3f(10, 2, 10);

void onInit(CRules@ this)
{
	this.addCommandID("init actor");
	this.addCommandID("sync actor");
	this.addCommandID("spawn actor");

	if (isServer())
	{
		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player !is null)
			{
				SpawnActor(this, player, SPAWN_POSITION);
			}
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	SpawnActor(this, player, SPAWN_POSITION);

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
	if (isClient() && cmd == this.getCommandID("spawn actor"))
	{
		CPlayer@ player = getPlayerByNetworkId(params.read_netid());
		Vec3f position(params);

		if (player !is null)
		{
			SpawnActor(this, player, position);
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

void SpawnActor(CRules@ this, CPlayer@ player, Vec3f position)
{
	Actor actor(player, position);
	Actor::SetActor(player, actor);

	if (!isClient())
	{
		CBitStream bs;
		bs.write_netid(player.getNetworkID());
		position.Serialize(bs);
		this.SendCommand(this.getCommandID("spawn actor"), bs, true);
	}
}
