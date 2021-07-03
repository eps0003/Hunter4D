#include "Object.as"
#include "Actor.as"

Vec3f SPAWN_POSITION = Vec3f(-1, 0, -1);

void onInit(CRules@ this)
{
	this.addCommandID("init object");
	this.addCommandID("sync object");
	this.addCommandID("set object color");
}

void onTick(CRules@ this)
{
	Object@[]@ objects = Object::getObjects();

	for (uint i = 0; i < objects.size(); i++)
	{
		Object@ object = objects[i];
		object.Update();
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

	Actor actor(player, SPAWN_POSITION);
	Actor::AddActor(actor);
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
	else if (!isServer() && cmd == this.getCommandID("set object color"))
	{
		Object@ object = Object::getObject(params.read_u16());
		if (object !is null)
		{
			object.color = SColor(params.read_u32());
		}
	}
}
