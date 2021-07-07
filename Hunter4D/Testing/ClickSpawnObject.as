#include "Object.as"

void onInit(CRules@ this)
{
	this.addCommandID("click");
}

void onTick(CRules@ this)
{
	if (isClient() && getControls().isKeyJustPressed(KEY_LBUTTON))
	{
		if (isServer())
		{
			SpawnObject();
		}
		else
		{
			CBitStream bs;
			bs.write_netid(getLocalPlayer().getNetworkID());
			this.SendCommand(this.getCommandID("click"), bs, false);
		}
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (isServer() && cmd == this.getCommandID("click"))
	{
		SpawnObject();
	}
}

void SpawnObject()
{
	Object object(Vec3f(2, 0, 10));
	Object::AddObject(object);
}
