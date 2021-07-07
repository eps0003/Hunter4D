#include "Object.as"
#include "Actor.as"

void onInit(CRules@ this)
{
	this.addCommandID("init object");
	this.addCommandID("sync object");
	this.addCommandID("remove object");
	this.addCommandID("set object collision flags");
	this.addCommandID("set object color");
	this.addCommandID("set object gravity");
}

void onTick(CRules@ this)
{
	Object@[]@ objects = Object::getObjects();

	for (uint i = 0; i < objects.size(); i++)
	{
		objects[i].PreUpdate();
	}

	for (uint i = 0; i < objects.size(); i++)
	{
		objects[i].Update();
	}

	for (uint i = 0; i < objects.size(); i++)
	{
		Object@ object = objects[i];
		object.PostUpdate();
		object.HandleSerializeTick();
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	// Sync all objects
	Object@[]@ objects = Object::getObjects();

	for (uint i = 0; i < objects.size(); i++)
	{
		objects[i].HandleSerializeInit(player);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("init object"))
	{
		Object object;
		object.HandleDeserializeInit(params);
	}
	else if (cmd == this.getCommandID("sync object"))
	{
		Object object;
		object.HandleDeserializeTick(params);
	}
	else if (cmd == this.getCommandID("remove object"))
	{
		Object object;
		object.HandleDeserializeRemove(params);
	}
	else if (!isServer() && cmd == this.getCommandID("set object collision flags"))
	{
		Object@ object = Object::getObject(params.read_u16());
		if (object !is null)
		{
			object.SetCollisionFlags(params.read_u8());
		}
	}
	else if (!isServer() && cmd == this.getCommandID("set object color"))
	{
		Object@ object = Object::getObject(params.read_u16());
		if (object !is null)
		{
			object.color = SColor(params.read_u32());
		}
	}
	else if (!isServer() && cmd == this.getCommandID("set object gravity"))
	{
		Object@ object = Object::getObject(params.read_u16());
		if (object !is null)
		{
			object.SetGravity(Vec3f(params));
		}
	}
}