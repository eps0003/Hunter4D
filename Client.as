#include "Actor.as"
#include "Camera.as"
#include "MapRenderer.as"

#define CLIENT_ONLY

void onInit(CRules@ this)
{
	print("Hunter3D loaded!", ConsoleColour::CRAZY);
	Render::addScript(Render::layer_prehud, "Client.as", "Render", 0);
	onRestart(this);
}

void onRestart(CRules@ this)
{
	Texture::createFromFile("pixel", "Pixel.png");
}

void onRender(CRules@ this)
{
	Actor@ actor = Actor::getMyActor();
	if (actor !is null)
	{
		actor.RenderHUD();
	}

	GUI::DrawText("Actors: " + Actor::getActorCount(), Vec2f(10, 30), color_black);
	GUI::DrawText("Objects: " + Object::getObjectCount(), Vec2f(10, 50), color_black);
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

	Camera::getCamera().Render();
	Map::getRenderer().Render();

	Object@[]@ objects = Object::getObjects();
	for (uint i = 0; i < objects.size(); i++)
	{
		objects[i].Render();
	}
}
