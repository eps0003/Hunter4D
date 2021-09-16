#include "SandboxActor.as"

void onInit(CRules@ this)
{
	this.addCommandID("init sandbox actor");
	this.addCommandID("sync sandbox actor");
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("init sandbox actor"))
	{
		SandboxActor actor;
		if (!actor.deserializeInit(params)) return;

		Actor::AddActor(actor);
	}
	else if (cmd == this.getCommandID("sync sandbox actor"))
	{
		SandboxActor actor;
		if (!actor.deserializeTick(params)) return;

		SandboxActor@ oldActor = cast<SandboxActor@>(Actor::getActor(actor.getID()));
		if (oldActor is null && oldActor.isMyActor()) return;

		oldActor = actor;
	}
}
