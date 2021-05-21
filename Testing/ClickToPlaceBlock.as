#include "Map.as"
#include "Ray.as"
#include "Camera.as"

uint index = 0;

void onInit(CRules@ this)
{
	this.addCommandID("place block");
	this.addCommandID("destroy block");
}

void onTick(CRules@ this)
{
	if (isClient())
	{
		CControls@ controls = getControls();

		bool left = controls.isKeyJustPressed(KEY_LBUTTON);
		bool right = controls.isKeyJustPressed(KEY_RBUTTON);

		if (left || right)
		{
			Camera@ camera = Camera::getCamera();
			Ray ray(camera.position, camera.rotation.dir());

			RaycastInfo raycast;
			if (ray.raycastBlock(100, false, raycast))
			{
				if (left)
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
						this.SendCommand(this.getCommandID("place block"), bs, false);
					}
				}
				else if (right)
				{
					Vec3f position = raycast.hitWorldPos;

					if (isServer())
					{
						DestroyBlock(position);
					}
					else
					{
						CBitStream bs;
						position.Serialize(bs);
						this.SendCommand(this.getCommandID("destroy block"), bs, false);
					}
				}
			}
		}
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (isServer())
	{
		if (cmd == this.getCommandID("place block"))
		{
			Vec3f position(params);
			PlaceBlock(position);
		}
		else if (cmd == this.getCommandID("destroy block"))
		{
			Vec3f position(params);
			DestroyBlock(position);
		}
	}
}

void PlaceBlock(Vec3f position)
{
	Map@ map = Map::getMap();
	map.SetBlockSafe(position, 1);
}

void DestroyBlock(Vec3f position)
{
	Map@ map = Map::getMap();
	map.SetBlockSafe(position, 0);
}
