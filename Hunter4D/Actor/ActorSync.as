#include "Actor.as"

Vec3f SPAWN_POSITION = Vec3f(4, 4, 4);

void onInit(CRules@ this)
{
	this.addCommandID("player loaded");
	this.addCommandID("init actor");
	this.addCommandID("sync actor");
	this.addCommandID("remove actor");
	this.addCommandID("set actor collision flags");
	this.addCommandID("set actor gravity");
}

void onTick(CRules@ this)
{
	Actor@[]@ actors = Actor::getActors();

	for (uint i = 0; i < actors.size(); i++)
	{
		actors[i].PreUpdate();
	}

	for (uint i = 0; i < actors.size(); i++)
	{
		actors[i].Update();
	}

	for (uint i = 0; i < actors.size(); i++)
	{
		Actor@ actor = actors[i];
		actor.PostUpdate();

		if (actor.getPlayer().isMyPlayer())
		{
			actor.SerializeTick();
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	// Sync all actors
	Actor@[]@ actor = Actor::getActors();
	for (uint i = 0; i < actor.size(); i++)
	{
		actor[i].SerializeInit(player);
	}
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	Actor::RemoveActor(player);
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	if (isServer())
	{
		Actor::RemoveActor(victim);
		Actor::AddActor(Actor(victim, SPAWN_POSITION));
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("init actor"))
	{
		Actor actor;
		actor.DeserializeInit(params);
	}
	else if (cmd == this.getCommandID("sync actor"))
	{
		Actor actor;
		actor.DeserializeTick(params);
	}
	else if (!isServer() && cmd == this.getCommandID("remove actor"))
	{
		Actor actor;
		actor.DeserializeRemove(params);
	}
	else if (isServer() && cmd == this.getCommandID("player loaded"))
	{
		u16 playerId;
		if (!params.saferead_netid(playerId)) return;

		CPlayer@ player = getPlayerByNetworkId(playerId);
		if (player is null) return;

		Actor::AddActor(Actor(player, SPAWN_POSITION));
	}
	else if (!isServer() && cmd == this.getCommandID("set object collision flags"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		Actor@ actor = Actor::getActor(id);
		if (actor is null) return;

		u8 collisionFlags;
		if (!params.saferead_u8(collisionFlags)) return;

		actor.SetCollisionFlags(collisionFlags);
	}
	else if (!isServer() && cmd == this.getCommandID("set actor gravity"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		Actor@ actor = Actor::getActor(id);
		if (actor is null) return;

		Vec3f gravity;
		if (!gravity.deserialize(params)) return;

		actor.SetGravity(gravity);
	}
}
