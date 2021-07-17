#include "SpleefActor.as"

void onInit(CRules@ this)
{
	this.addCommandID("init spleef actor");
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("init spleef actor"))
	{
		SpleefActor actor;
		actor.DeserializeInit(params);
		Actor::AddActor(actor);
	}
}
