#include "Doll.as"

void onInit(CRules@ this)
{
	this.addCommandID("init doll");
	this.addCommandID("set doll red light");
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("init doll"))
	{
		Doll doll;
		if (!doll.deserializeInit(params)) return;

		Object::AddObject(doll);
	}
	else if (!isServer() && cmd == this.getCommandID("set doll red light"))
	{
		Object@ object;
		if (!Object::saferead(params, @object)) return;

		Doll@ doll = cast<Doll@>(object);
		if (doll is null) return;

		bool redLight;
		if (!params.saferead_bool(redLight)) return;

		doll.SetRedLight(redLight);
	}
}
