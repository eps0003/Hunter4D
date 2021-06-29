#include "Actor.as"
#include "Camera.as"
#include "MapRenderer.as"
#include "Loader.as"

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
	if (!Loader::getLoader().isLoaded()) return;

	Actor@ actor = Actor::getMyActor();
	if (actor !is null)
	{
		actor.RenderHUD();
	}
}

void Render(int id)
{
	// Background color
	Vec2f screenDim = getDriver().getScreenDimensions();
	GUI::DrawRectangle(Vec2f_zero, screenDim, SColor(255, 165, 189, 200));

	if (!Loader::getLoader().isLoaded()) return;

	Render::SetAlphaBlend(false);
	Render::SetZBuffer(true, true);
	Render::SetBackfaceCull(true);
	Render::ClearZ();

	Camera::getCamera().Render();
	MapRenderer::getRenderer().Render();

	Actor@[] actors = Actor::getActors();
	for (uint i = 0; i < actors.size(); i++)
	{
		actors[i].Render();
	}

	Object@[]@ objects = Object::getObjects();
	for (uint i = 0; i < objects.size(); i++)
	{
		objects[i].Render();
	}

	GUI::DrawText("Actors: " + Actor::getActorCount(), Vec2f(10, 30), color_black);
	GUI::DrawText("Objects: " + Object::getObjectCount(), Vec2f(10, 50), color_black);
}
