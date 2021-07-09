#include "Map.as"
#include "Ray.as"
#include "Camera.as"
#include "Object.as"
#include "Actor.as"
#include "Collision.as"

#define CLIENT_ONLY

Camera@ camera;
Map@ map;
CControls@ controls;

void onInit(CRules@ this)
{
	this.addCommandID("place block");
	this.addCommandID("destroy block");

	onRestart(this);
}

void onRestart(CRules@ this)
{
	@camera = Camera::getCamera();
	@map = Map::getMap();
	@controls = getControls();
}

void onTick(CRules@ this)
{
	if (this.hasScript("LoadingScreen.as")) return;

	bool left = controls.isKeyJustPressed(KEY_LBUTTON);
	bool right = controls.isKeyJustPressed(KEY_RBUTTON);

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
				Map::getMap().ClientSetBlockSafe(position, 0);
			}
		}
	}
}
