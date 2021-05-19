#include "Mouse.as"

void onTick(CRules@ this)
{
	Mouse::getMouse().Update();
}
