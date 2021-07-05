#include "Mouse.as"

#define CLIENT_ONLY

Mouse@ mouse;

void onInit(CRules@ this)
{
	@mouse = Mouse::getMouse();
}

void onTick(CRules@ this)
{
	mouse.Update();
}

void onRender(CRules@ this)
{
	if (mouse is null) return;

	mouse.Interpolate();
	mouse.Render();
}
