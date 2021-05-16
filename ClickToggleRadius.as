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
            ToggleRadius(Object::getMyObject());
        }
        else
        {
            CBitStream bs;
            bs.write_netid(getLocalPlayer().getNetworkID());
            this.SendCommand(this.getCommandID("click"), bs, true);
        }
    }
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
    if (isServer() && cmd == this.getCommandID("click"))
    {
        u16 id = params.read_netid();

        CPlayer@ player = getPlayerByNetworkId(id);
        Object@ object = Object::getObject(player);

        if (object !is null)
        {
            ToggleRadius(object);
        }
    }
}

void ToggleRadius(Object@ object)
{
    object.radius = object.radius == 20 ? 40 : 20;
}
