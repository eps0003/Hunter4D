#include "Object.as"
#include "Camera.as"

#define CLIENT_ONLY

void onInit(CRules@ this)
{
	Render::addScript(Render::layer_prehud, "Client.as", "Render", 0);
	onRestart(this);
}

void onRestart(CRules@ this)
{
	Texture::createFromFile("pixel", "Pixel.png");
}

void onRender(CRules@ this)
{
	Object@ object = Object::getMyObject();
	if (object !is null)
	{
        object.RenderHUD();
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

	Object@ object = Object::getMyObject();
	if (object !is null)
	{
		object.Render();
	}
}
