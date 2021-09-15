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

		if (actor.isMyActor())
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
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("init actor"))
	{
		Actor actor;
		actor.DeserializeInit(params);
		Actor::AddActor(actor);
	}
	else if (cmd == this.getCommandID("sync actor"))
	{
		Actor actor;
		actor.DeserializeTick(params);

		Actor@ oldActor = Actor::getActor(actor.getID());
		if (oldActor !is null && !oldActor.isMyActor())
		{
			oldActor = actor;
		}
	}
	else if (!isServer() && cmd == this.getCommandID("remove actor"))
	{
		Actor actor;
		actor.DeserializeRemove(params);
		Actor::RemoveActor(actor);
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
