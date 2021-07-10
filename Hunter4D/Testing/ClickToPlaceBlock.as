#include "Map.as"
#include "Ray.as"
#include "Camera.as"
#include "Object.as"
#include "Actor.as"
#include "Collision.as"
#include "Mouse.as"

#define CLIENT_ONLY

Mouse@ mouse;
Camera@ camera;
Map@ map;
CControls@ controls;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	@mouse = Mouse::getMouse();
	@camera = Camera::getCamera();
	@map = Map::getMap();
	@controls = getControls();
}

void onTick(CRules@ this)
{
	if (!mouse.isInControl()) return;

	bool left = controls.isKeyJustPressed(controls.getActionKeyKey(AK_ACTION1));
	bool right = controls.isKeyJustPressed(controls.getActionKeyKey(AK_ACTION2));

	if (left || right)
	{
		Ray ray(camera.position, camera.rotation.dir());

		RaycastInfo raycast;
		if (ray.raycastBlock(6, false, raycast))
		{
			if (left)
			{
				Vec3f position = raycast.hitWorldPos + raycast.normal;
				map.ClientSetBlockSafe(position, SColor(255, 100, 100, 100));
			}
			else
			{
				Vec3f position = raycast.hitWorldPos;
				map.ClientSetBlockSafe(position, 0);
			}
		}
	}
}
