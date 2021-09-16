#include "Actor.as"

void onInit(CRules@ this)
{
	this.addCommandID("init actor");
	this.addCommandID("sync actor");
	this.addCommandID("remove actor");
	this.addCommandID("set actor collision flags");
	this.addCommandID("set actor gravity");
	this.addCommandID("set actor health");
}

void onTick(CRules@ this)
{
	Actor@[]@ actors = Actor::getActors();

	for (int i = actors.size() - 1; i >= 0; i--)
	{
		actors[i].PreUpdate();
	}

	for (int i = actors.size() - 1; i >= 0; i--)
	{
		actors[i].Update();
	}

	for (int i = actors.size() - 1; i >= 0; i--)
	{
		Actor@ actor = actors[i];
		actor.PostUpdate();

		if (actor.isMyActor())
		{
			actor.SerializeTick();
		}
	}

	for (int i = actors.size() - 1; i >= 0; i--)
	{
		Actor@ actor = actors[i];
		if (actor.isMyActor())
		{
			CBitStream bs;
			bs.write_u16(i);
			actor.SerializeTick(bs);
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
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("init actor"))
	{
		Actor actor;
		if (!actor.deserializeInit(params)) return;

		Actor::AddActor(actor);
	}
	else if (cmd == this.getCommandID("sync actor"))
	{
		u16 index;
		if (!params.saferead_u16(index)) return;

		Actor@ oldActor = Actor::getActorByIndex(index);
		if (oldActor is null || oldActor.isMyActor()) return;

		Actor actor;
		if (!actor.deserializeTick(params)) return;

		oldActor = actor;

	}
	else if (!isServer() && cmd == this.getCommandID("remove actor"))
	{
		u16 index;
		if (!params.saferead_u16(index)) return;

		Actor actor;
		if (!actor.deserializeRemove(params)) return;

		Actor::RemoveActorByIndex(index);
	}
	else if (!isServer() && cmd == this.getCommandID("set object collision flags"))
	{
		Actor@ actor;
		if (!Actor::saferead(params, @actor)) return;

		u8 collisionFlags;
		if (!params.saferead_u8(collisionFlags)) return;

		actor.SetCollisionFlags(collisionFlags);
	}
	else if (!isServer() && cmd == this.getCommandID("set actor gravity"))
	{
		Actor@ actor;
		if (!Actor::saferead(params, @actor)) return;

		Vec3f gravity;
		if (!gravity.deserialize(params)) return;

		actor.SetGravity(gravity);
	}
	else if (!isServer() && cmd == this.getCommandID("set actor health"))
	{
		Actor@ actor;
		if (!Actor::saferead(params, @actor)) return;

		float health;
		if (!params.saferead_u8(health)) return;

		actor.SetHealth(health);
	}
}
