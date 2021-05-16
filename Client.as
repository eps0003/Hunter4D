#include "Object.as"

#define CLIENT_ONLY

void onTick(CRules@ this)
{
    if (getControls().isKeyJustPressed(KEY_LBUTTON))
    {
        CBitStream bs;
        bs.write_netid(getLocalPlayer().getNetworkID());
        this.SendCommand(this.getCommandID("click"), bs);
    }
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
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

void onRender(CRules@ this)
{
    Object@[] objects = Object::getObjects();
    for (uint i = 0; i < objects.size(); i++)
    {
        objects[i].Render();
    }
}
