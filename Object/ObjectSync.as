#include "Object.as"

void onInit(CRules@ this)
{
    this.addCommandID("init object");
    this.addCommandID("sync object");

    if (isServer())
    {
        Object::AddObject(Object(Vec3f()));
    }
}

void onTick(CRules@ this)
{
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

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
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
