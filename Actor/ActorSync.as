#include "Actor.as"

Vec3f SPAWN_POSITION = Vec3f(50, 10, 50);

void onInit(CRules@ this)
{
	this.addCommandID("init actor");
	this.addCommandID("sync actor");
	this.addCommandID("spawn actor");
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	if (isServer())
	{
		Actor::RemoveActor(player);
	}
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
	if (cmd == this.getCommandID("init actor"))
	{
		Actor actor;
		actor.HandleDeserializeInit(params);
	}
	else if (cmd == this.getCommandID("sync actor"))
	{
		Actor actor;
		actor.HandleDeserializeTick(params);
	}
	else if (isServer() && cmd == this.getCommandID("spawn actor"))
	{
		CPlayer@ player = getPlayerByNetworkId(params.read_netid());
		if (player !is null)
		{
			Actor::AddActor(Actor(player, SPAWN_POSITION));
		}
	}
}
