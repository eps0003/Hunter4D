#include "HunterActor.as"

void onInit(CRules@ this)
{
	this.addCommandID("init hunter actor");
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("init hunter actor"))
	{
		HunterActor actor;
		actor.DeserializeInit(params);
		Actor::AddActor(actor);
	}
}
