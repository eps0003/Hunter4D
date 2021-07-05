#include "Actor.as"

Vec3f SPAWN_POSITION = Vec3f(4, 4, 4);

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
				Actor actor(player, SPAWN_POSITION);
				Actor::AddActor(actor);
			}
		}
	}
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	if (isServer())
	{
		Actor::RemoveActor(player);
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
			Actor actor(player, SPAWN_POSITION);
			Actor::AddActor(actor);
		}
	}
}
