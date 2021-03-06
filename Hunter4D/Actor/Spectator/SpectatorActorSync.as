#include "SpectatorActor.as"

void onInit(CRules@ this)
{
	this.addCommandID("init spectator actor");
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("init spectator actor"))
	{
		SpectatorActor actor;
		if (!actor.deserializeInit(params)) return;

		Actor::AddActor(actor);
	}
}
