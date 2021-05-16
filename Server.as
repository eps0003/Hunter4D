#include "Object.as"

#define SERVER_ONLY

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
