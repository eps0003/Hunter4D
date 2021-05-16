#include "Object.as"

#define CLIENT_ONLY

void onRender(CRules@ this)
{
    Object@[] objects = Object::getObjects();
    for (uint i = 0; i < objects.size(); i++)
    {
        objects[i].Render();
    }
}
