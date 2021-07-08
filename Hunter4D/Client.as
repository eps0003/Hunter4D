#include "Object.as"
#include "Actor.as"
#include "Camera.as"
#include "MapRenderer.as"

#define CLIENT_ONLY

int id;

void onInit(CRules@ this)
{
	print("Hunter3D loaded!", ConsoleColour::CRAZY);

	id = Render::addScript(Render::layer_prehud, "Client.as", "Render", 0);

	CBitStream bs;
	bs.write_netid(getLocalPlayer().getNetworkID());
	this.SendCommand(this.getCommandID("spawn actor"), bs, false);

	Texture::createFromFile("pixel", "Pixel.png");
}

void onRestart(CRules@ this)
{
	Render::RemoveScript(id);
	this.RemoveScript("Client.as");
}

void onRender(CRules@ this)
{
	Actor@ actor = Actor::getMyActor();
	if (actor !is null)
	{
		actor.RenderHUD();
	}

	Actor@[]@ actors = Actor::getActors();
	for (uint i = 0; i < actors.size(); i++)
	{
		Actor@ actor = actors[i];
		if (actor.isNameplateVisible())
		{
			actor.RenderNameplate();
		}
	}

	GUI::DrawText("Actors: " + Actor::getActorCount(), Vec2f(10, 30), color_black);
	GUI::DrawText("Objects: " + Object::getObjectCount(), Vec2f(10, 50), color_black);
}

void Render(int id)
{
	Render::SetAlphaBlend(false);
	Render::SetZBuffer(true, true);
	Render::SetBackfaceCull(true);
	Render::ClearZ();

	Camera@ camera = Camera::getCamera();
	camera.Interpolate();
	camera.Render();

	Map::getRenderer().Render();

	Actor@[]@ actors = Actor::getActors();
	for (uint i = 0; i < actors.size(); i++)
	{
		Actor@ actor = actors[i];
		actor.Interpolate();
		if (actor.isVisible())
		{
			actor.Render();
		}
	}

	Object@[]@ objects = Object::getObjects();
	for (uint i = 0; i < objects.size(); i++)
	{
		Object@ object = objects[i];
		object.Interpolate();
		if (object.isVisible())
		{
			object.Render();
		}
	}
}
