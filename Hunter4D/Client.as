#include "Object.as"
#include "Actor.as"
#include "Camera.as"
#include "MapRenderer.as"

#define CLIENT_ONLY

int id;
Actor@[]@ actors;
Object@[]@ objects;
Camera@ camera;
MapRenderer@ mapRenderer;

void onInit(CRules@ this)
{
	print("Hunter3D loaded!", ConsoleColour::CRAZY);

	id = Render::addScript(Render::layer_prehud, "Client.as", "Render", 0);

	CBitStream bs;
	bs.write_netid(getLocalPlayer().getNetworkID());
	this.SendCommand(this.getCommandID("player loaded"), bs, false);

	Texture::createFromFile("pixel", "Pixel.png");

	@camera = Camera::getCamera();
	@mapRenderer = Map::getRenderer();
}

void onRestart(CRules@ this)
{
	Render::RemoveScript(id);
	this.RemoveScript("Client.as");
}

void onTick(CRules@ this)
{
	@actors = Actor::getActors();
	@objects = Object::getObjects();
}

void onRender(CRules@ this)
{
	for (uint i = 0; i < actors.size(); i++)
	{
		Actor@ actor = actors[i];

		if (actor.getPlayer().isMyPlayer())
		{
			actor.RenderHUD();
		}

		if (actor.isNameplateVisible())
		{
			actor.RenderNameplate();
		}
	}

	GUI::DrawText("Actors: " + actors.size(), Vec2f(10, 30), color_black);
	GUI::DrawText("Objects: " + objects.size(), Vec2f(10, 50), color_black);
}

void Render(int id)
{
	Render::SetAlphaBlend(false);
	Render::SetZBuffer(true, true);
	Render::SetBackfaceCull(true);
	Render::ClearZ();

	camera.Interpolate();
	camera.Render();

	mapRenderer.Render();

	for (uint i = 0; i < actors.size(); i++)
	{
		Actor@ actor = actors[i];
		actor.Interpolate();
		if (actor.isVisible())
		{
			actor.Render();
		}
	}

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
