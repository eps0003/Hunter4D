#include "Map.as"
#include "Ray.as"
#include "Camera.as"

uint index = 0;

void onInit(CRules@ this)
{
	this.addCommandID("click");
}

void onTick(CRules@ this)
{
	if (isClient() && getControls().isKeyJustPressed(KEY_LBUTTON))
	{
		Camera@ camera = Camera::getCamera();
		Ray ray(camera.position, camera.rotation.dir());

		RaycastInfo raycast;
		if (ray.raycastBlock(100, false, raycast))
		{
			Vec3f position = raycast.hitWorldPos + raycast.normal;

			if (isServer())
			{
				PlaceBlock(position);
			}
			else
			{
				CBitStream bs;
				position.Serialize(bs);
				this.SendCommand(this.getCommandID("click"), bs, false);
			}
		}
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (isServer() && cmd == this.getCommandID("click"))
	{
		Vec3f position(params);
		PlaceBlock(position);
	}
}

void PlaceBlock(Vec3f position)
{
	Map@ map = Map::getMap();
	map.SetBlockSafe(position, 1);
}
