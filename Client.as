#include "Object.as"
#include "Camera.as"

#define CLIENT_ONLY

void onInit(CRules@ this)
{
	Render::addScript(Render::layer_prehud, "Client.as", "Render", 0);
}

void onRender(CRules@ this)
{
    Object@[] objects = Object::getObjects();
    for (uint i = 0; i < objects.size(); i++)
    {
        objects[i].Render();
    }
}

void Render(int id)
{
	// Background color
	Vec2f screenDim = getDriver().getScreenDimensions();
	GUI::DrawRectangle(Vec2f_zero, screenDim, SColor(255, 165, 189, 200));

	Render::SetAlphaBlend(false);
	Render::SetZBuffer(true, true);
	Render::SetBackfaceCull(true);
	Render::ClearZ();

	Camera@ camera = Camera::getCamera();
	camera.Render();
}
