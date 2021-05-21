#include "Mouse.as"

#define CLIENT_ONLY

void onTick(CRules@ this)
{
	Mouse::getMouse().Update();
}

void onRender(CRules@ this)
{
	Mouse::getMouse().Render();
}
