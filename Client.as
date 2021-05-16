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

void onRender(CRules@ this)
{
    Object@[] objects = Object::getObjects();
    for (uint i = 0; i < objects.size(); i++)
    {
        objects[i].Render();
    }
}
