#include "SquidGamer.as"

void onInit(CRules@ this)
{
	this.addCommandID("init squid gamer");
	this.addCommandID("squid gamer pushed");
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("init squid gamer"))
	{
		SquidGamer actor;
		if (!actor.deserializeInit(params)) return;

		Actor::AddActor(actor);
	}
}
