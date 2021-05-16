#include "Object.as"

void onInit(CRules@ this)
{
    this.addCommandID("init object");
    this.addCommandID("sync object");
    this.addCommandID("set object radius");

    if (isServer())
    {
        for (uint i = 0; i < getPlayerCount(); i++)
        {
            CPlayer@ player = getPlayer(i);
            Object object(player, Vec3f(), 20);
            Object::SetObject(player, object);

            CBitStream bs;
            object.SerializeInit(bs);
            this.SendCommand(this.getCommandID("init object"), bs, true);
        }
    }
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
    Object object(player, Vec3f(), 20);
    Object::SetObject(player, object);

    for (uint i = 0; i < getPlayerCount(); i++)
    {
        CPlayer@ player = getPlayer(i);
        Object@ object = Object::getObject(player);

        if (object !is null)
        {
            CBitStream bs;
            object.SerializeInit(bs);
            this.SendCommand(this.getCommandID("init object"), bs, true);
        }
    }
}

void onTick(CRules@ this)
{
    if (!isClient())
    {
        for (uint i = 0; i < getPlayerCount(); i++)
        {
            CPlayer@ player = getPlayer(i);
            Object@ object = Object::getObject(player);

            if (object !is null)
            {
                CBitStream bs;
                object.SerializeTick(bs);
                this.SendCommand(this.getCommandID("sync object"), bs, true);
            }
        }
    }

    Object@[] objects = Object::getObjects();
    for (uint i = 0; i < objects.size(); i++)
    {
        objects[i].Update();
    }
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
    if (!isServer())
    {
        if (cmd == this.getCommandID("init object"))
        {
            Object object(params);
            Object::SetObject(object.player, object);
        }
        else if (cmd == this.getCommandID("sync object"))
        {
            Object newObject(params);
            Object@ oldObject = Object::getMyObject();

            if (oldObject !is null)
            {
                oldObject = newObject;
            }
        }
        else if (cmd == this.getCommandID("set object radius"))
        {
            u16 id = params.read_netid();

            CPlayer@ player = getPlayerByNetworkId(id);
            Object@ object = Object::getObject(player);

            if (object !is null)
            {
                object.radius = params.read_f32();
            }
        }
    }
}
