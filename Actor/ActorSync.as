#include "Actor.as"

Vec3f SPAWN_POSITION = Vec3f(4, 4, 4);

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
				Actor::AddActor(actor);
			}
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	Actor actor(player, SPAWN_POSITION);
	Actor::AddActor(actor);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	Actor::RemoveActor(player);
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
}
