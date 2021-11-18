#include "Object.as"
#include "Camera.as"
#include "MapRenderer.as"
#include "Particle.as"
#include "Loading.as"

#define CLIENT_ONLY

int id;
Actor@[]@ actors;
Object@[]@ objects;
Camera@ camera;
MapRenderer@ mapRenderer;
ParticleManager@ particleManager;

void onInit(CRules@ this)
{
	print("Hunter3D loaded!", ConsoleColour::CRAZY);
	Loading::SetMyPlayerLoaded(true);

	id = Render::addScript(Render::layer_prehud, "Client.as", "Render", 0);

	Texture::createFromFile("pixel", "Pixel.png");

	@particleManager = Particles::getManager();
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
	if (g_videorecording) return;

	for (uint i = 0; i < actors.size(); i++)
	{
		Actor@ actor = actors[i];

		if (actor.isMyActor())
		{
			actor.RenderHUD();

			for (uint i = 0; i < objects.size(); i++)
			{
				objects[i].RenderHUD();
			}
		}

		if (actor.isNameplateVisible())
		{
			actor.RenderNameplate();
		}
	}

	GUI::DrawText("Actors: " + Actor::getVisibleActorCount() + " / "  + actors.size(), Vec2f(10, 30), color_black);
	GUI::DrawText("Objects: " + Object::getVisibleObjectCount() + " / "  + objects.size(), Vec2f(10, 50), color_black);
	GUI::DrawText("Chunks: " + mapRenderer.visibleChunkCount + " / " + mapRenderer.chunkCount, Vec2f(10, 70), color_black);
	GUI::DrawText("Particles: " + particleManager.getParticleCount(), Vec2f(10, 90), color_black);
}

void Render(int id)
{
	Render::SetAlphaBlend(false);
	Render::SetZBuffer(true, true);
	Render::SetBackfaceCull(true);
	Render::ClearZ();

	if (!Actor::myActorExists()) return;

	camera.Interpolate();
	camera.Render();

	mapRenderer.Render();

	particleManager.Render();

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
