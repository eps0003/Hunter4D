#include "Doll.as"

void onInit(CRules@ this)
{
	this.addCommandID("init doll");
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("init doll"))
	{
		Doll doll;
		if (!doll.deserializeInit(params)) return;

		Object::AddObject(doll);
	}
}
