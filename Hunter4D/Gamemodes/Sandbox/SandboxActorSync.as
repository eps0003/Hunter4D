#include "SandboxActor.as"

void onInit(CRules@ this)
{
	this.addCommandID("init sandbox actor");
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("init sandbox actor"))
	{
		SandboxActor().DeserializeInit(params);
	}
}
