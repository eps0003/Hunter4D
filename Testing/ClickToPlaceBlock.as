#include "Map.as"
#include "Ray.as"
#include "Camera.as"
#include "Object.as"
#include "Blob.as"

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
					Vec3f position = raycast.hitPos + raycast.normal * 2;

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
	Object::AddObject(Blob(position));

	// Object@[]@ objects = Object::getObjects();
	// for (uint i = 0; i < objects.size(); i++)
	// {
	// 	print("float!");
	// 	objects[i].SetGravity(Vec3f());
	// }

	// Map@ map = Map::getMap();
	// map.SetBlockSafe(position, SColor(255, 100, 100, 100));
}

void DestroyBlock(Vec3f position)
{
	// Object@[]@ objects = Object::getObjects();
	// for (uint i = 0; i < objects.size(); i++)
	// {
	// 	print("fall!");
	// 	objects[i].SetGravity(Vec3f(0, -0.04f, 0));
	// }

	// Map@ map = Map::getMap();
	// map.SetBlockSafe(position, 0);
}
