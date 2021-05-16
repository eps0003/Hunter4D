#include "Object.as"

#define SERVER_ONLY

void onInit(CRules@ this)
{
    for (uint i = 0; i < getPlayerCount(); i++)
    {
        CPlayer@ player = getPlayer(i);
        Object object(player, Vec2f(100, 100), 20);
        Object::SetObject(player, object);

        CBitStream bs;
        object.SerializeInit(bs);
        this.SendCommand(this.getCommandID("init object"), bs, true);
    }
}

void onTick(CRules@ this)
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

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
    Object object(player, Vec2f(100, 100), 20);
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

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
    if (cmd == this.getCommandID("click"))
    {
        u16 id = params.read_netid();

        CPlayer@ player = getPlayerByNetworkId(id);
        Object@ object = Object::getObject(player);

        if (object !is null)
        {
            object.radius = object.radius == 20 ? 40 : 20;
        }
    }
}
