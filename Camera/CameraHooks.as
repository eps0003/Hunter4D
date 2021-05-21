#include "Camera.as"

#define CLIENT_ONLY

void onTick(CRules@ this)
{
	Camera::getCamera().Update();
}
