#include "Camera.as"

#define CLIENT_ONLY

Camera@ camera;

void onInit(CRules@ this)
{
	@camera = Camera::getCamera();
}

void onTick(CRules@ this)
{
	camera.Update();
}
