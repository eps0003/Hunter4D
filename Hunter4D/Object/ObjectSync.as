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
		object.HandledeserializeInit(params);
	}
	else if (cmd == this.getCommandID("sync object"))
	{
		Object object;
		object.HandledeserializeTick(params);
	}
	else if (cmd == this.getCommandID("remove object"))
	{
		Object object;
		object.HandledeserializeRemove(params);
	}
	else if (!isServer() && cmd == this.getCommandID("set object collision flags"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		Object@ object = Object::getObject(id);
		if (object is null) return;

		u8 collisionFlags;
		if (!params.saferead_u8(collisionFlags)) return;

		object.SetCollisionFlags(collisionFlags);
	}
	else if (!isServer() && cmd == this.getCommandID("set object color"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		Object@ object = Object::getObject(id);
		if (object is null) return;

		uint colorInt;
		if (!params.saferead_u32(colorInt)) return;

		object.color = SColor(colorInt);
	}
	else if (!isServer() && cmd == this.getCommandID("set object gravity"))
	{
		u16 id;
		if (!params.saferead_u16(id)) return;

		Object@ object = Object::getObject(id);
		if (object is null) return;

		Vec3f gravity;
		if (!gravity.deserialize(params)) return;

		object.SetGravity(gravity);
	}
}
