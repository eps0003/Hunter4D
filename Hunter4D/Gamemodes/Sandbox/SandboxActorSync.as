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
		actor.DeserializeInit(params);
		Actor::AddActor(actor);
	}
	else if (cmd == this.getCommandID("sync sandbox actor"))
	{
		SandboxActor actor;
		actor.DeserializeTick(params);

		SandboxActor@ oldActor = cast<SandboxActor@>(Actor::getActor(actor.getID()));
		if (oldActor !is null && !oldActor.isMyActor())
		{
			oldActor = actor;
		}
	}
}
