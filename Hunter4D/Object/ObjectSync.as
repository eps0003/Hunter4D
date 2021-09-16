#include "Object.as"
#include "Actor.as"

void onInit(CRules@ this)
{
	this.addCommandID("init object");
	this.addCommandID("sync object");
	this.addCommandID("remove object");
	this.addCommandID("set object name");
	this.addCommandID("set object collision flags");
	this.addCommandID("set object gravity");
	this.addCommandID("set object friction");
	this.addCommandID("set object elasticity");
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

		if (!isClient())
		{
			object.SerializeTick();
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	// Sync all objects
	Object@[]@ objects = Object::getObjects();
	for (uint i = 0; i < objects.size(); i++)
	{
		objects[i].SerializeInit(player);
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("init object"))
	{
		Object object;
		if (!object.deserializeInit(params)) return;

		Object::AddObject(object);
	}
	else if (cmd == this.getCommandID("sync object"))
	{
		Object object;
		if (!object.deserializeTick(params)) return;

		Object@ oldObject = Object::getObject(object.getID());
		if (oldObject is null) return;

		oldObject = object;
	}
	else if (!isServer() && cmd == this.getCommandID("remove object"))
	{
		Object object;
		if (!object.deserializeRemove(params)) return;

		Object::RemoveObject(object);
	}
	else if (!isServer() && cmd == this.getCommandID("set object name"))
	{
		Object@ object;
		if (!Object::saferead(params, @object)) return;

		string name;
		if (!params.saferead_string(name)) return;

		object.SetName(name);
	}
	else if (!isServer() && cmd == this.getCommandID("set object collision flags"))
	{
		Object@ object;
		if (!Object::saferead(params, @object)) return;

		u8 collisionFlags;
		if (!params.saferead_u8(collisionFlags)) return;

		object.SetCollisionFlags(collisionFlags);
	}
	else if (!isServer() && cmd == this.getCommandID("set object gravity"))
	{
		Object@ object;
		if (!Object::saferead(params, @object)) return;

		Vec3f gravity;
		if (!gravity.deserialize(params)) return;

		object.SetGravity(gravity);
	}
	else if (!isServer() && cmd == this.getCommandID("set object friction"))
	{
		Object@ object;
		if (!Object::saferead(params, @object)) return;

		float friction;
		if (!params.saferead_f32(friction)) return;

		object.SetFriction(friction);
	}
	else if (!isServer() && cmd == this.getCommandID("set object elasticity"))
	{
		Object@ object;
		if (!Object::saferead(params, @object)) return;

		float elasticity;
		if (!params.saferead_f32(elasticity)) return;

		object.SetElasticity(elasticity);
	}
}
