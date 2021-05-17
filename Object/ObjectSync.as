#include "Object.as"

void onInit(CRules@ this)
{
	this.addCommandID("init object");
	this.addCommandID("sync object");
}

void onTick(CRules@ this)
{
	if (isServer() && getGameTime() == 10)
	{
		Object::AddObject(Object(Vec3f(2, 0, 10)));
	}

	Object@[]@ objects = Object::getObjects();

	for (uint i = 0; i < objects.size(); i++)
	{
		Object@ object = objects[i];

		objects[i].Update();

		// Sync to clients if not localhost
		if (!isClient())
		{
			CBitStream bs;
			object.SerializeTick(bs);
			this.SendCommand(this.getCommandID("sync object"), bs, true);
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	// Sync all objects
	Object@[]@ objects = Object::getObjects();

	for (uint i = 0; i < objects.size(); i++)
	{
		Object@ object = objects[i];

		CBitStream bs;
		object.SerializeInit(bs);
		this.SendCommand(this.getCommandID("init object"), bs, player);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (isClient())
	{
		if (cmd == this.getCommandID("init object"))
		{
			Object object(params);
			Object::AddObject(object);
		}
		else if (cmd == this.getCommandID("sync object"))
		{
			Object newObject(params);
			Object@ oldObject = Object::getObject(newObject.id);
			if (oldObject !is null)
			{
				oldObject = newObject;
			}
		}
	}
}
