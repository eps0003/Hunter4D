#include "Map.as"
#include "Ray.as"
#include "Camera.as"
#include "Object.as"
#include "Actor.as"
#include "Collision.as"

void onInit(CRules@ this)
{
	this.addCommandID("place block");
	this.addCommandID("destroy block");
}

void onTick(CRules@ this)
{
	if (isClient() && !this.hasScript("LoadingScreen.as"))
	{
		CControls@ controls = getControls();

		bool left = controls.isKeyJustPressed(KEY_LBUTTON);
		bool right = controls.isKeyJustPressed(KEY_RBUTTON);

		if (left || right)
		{
			Camera@ camera = Camera::getCamera();
			Ray ray(camera.position, camera.rotation.dir());

			RaycastInfo raycast;
			if (ray.raycastBlock(6, false, raycast))
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
			Vec3f position;
			if (!position.deserialize(params)) return;

			PlaceBlock(position);
		}
		else if (cmd == this.getCommandID("destroy block"))
		{
			Vec3f position;
			if (!position.deserialize(params)) return;

			DestroyBlock(position);
		}
	}
}

void PlaceBlock(Vec3f position)
{
	// Prevent placing blocks inside objects
	Object@[]@ objects = Object::getObjects();
	for (uint i = 0; i < objects.size(); i++)
	{
		Object@ object = objects[i];

		bool hasCollider = object.hasCollider();
		bool collidesWithBlocks = object.hasCollisionFlags(CollisionFlag::Blocks);
		bool intersectsVoxel = object.getCollider().intersectsVoxel(object.position, position);

		if (hasCollider && collidesWithBlocks && intersectsVoxel)
		{
			return;
		}
	}

	// Prevent placing blocks inside actors
	Actor@[]@ actors = Actor::getActors();
	for (uint i = 0; i < actors.size(); i++)
	{
		Actor@ actor = actors[i];

		bool hasCollider = actor.hasCollider();
		bool collidesWithBlocks = actor.hasCollisionFlags(CollisionFlag::Blocks);
		bool intersectsVoxel = actor.getCollider().intersectsVoxel(actor.position, position);

		if (hasCollider && collidesWithBlocks && intersectsVoxel)
		{
			return;
		}
	}

	Map::getMap().SetBlockSafe(position, SColor(255, 100, 100, 100));
}

void DestroyBlock(Vec3f position)
{
	Map::getMap().SetBlockSafe(position, 0);
}
