#include "AABB.as"
#include "CollisionFlags.as"
#include "Vec3f.as"
#include "Map.as"

shared interface ICollision
{
	AABB@ getCollider();
	void SetCollider(AABB@ collider);
	bool hasCollider();
	void AddCollisionFlags(u8 flags);
	void RemoveCollisionFlags(u8 flags);
	void SetCollisionFlags(u8 flags);
	bool hasCollisionFlags(u8 flags);
	bool isOnGround();
}

shared bool CollisionX(ICollision@ thing, Vec3f &inout position, Vec3f &inout velocity)
{
	bool collided = false;

	if (thing.hasCollider())
	{
		AABB@ collider = thing.getCollider();
		Vec3f xPosition = position + Vec3f(velocity.x, 0, 0);

		if (thing.hasCollisionFlags(CollisionFlag::Blocks) && velocity.x != 0 && collider.intersectsNewSolid(position, xPosition))
		{
			if (velocity.x > 0)
			{
				position.x = Maths::Ceil(position.x + collider.max.x) - collider.max.x - 0.0001f;
			}
			else
			{
				position.x = Maths::Floor(position.x + collider.min.x) - collider.min.x + 0.0001f;
			}

			collided = true;
		}
		else if (thing.hasCollisionFlags(CollisionFlag::MapEdge) && collider.intersectsMapEdge(xPosition))
		{
			if (velocity.x > 0)
			{
				position.x = Map::getMap().dimensions.x - collider.max.x - 0.0001f;
			}
			else
			{
				position.x = -collider.min.x;
			}

			collided = true;
		}
	}

	if (collided)
	{
		velocity.x = 0;
	}
	else
	{
		position.x += velocity.x;
	}

	return collided;
}

shared bool CollisionZ(ICollision@ thing, Vec3f &inout position, Vec3f &inout velocity)
{
	bool collided = false;

	if (thing.hasCollider())
	{
		AABB@ collider = thing.getCollider();
		Vec3f zPosition = position + Vec3f(0, 0, velocity.z);

		if (thing.hasCollisionFlags(CollisionFlag::Blocks) && velocity.z != 0 && collider.intersectsNewSolid(position, zPosition))
		{
			if (velocity.z > 0)
			{
				position.z = Maths::Ceil(position.z + collider.max.z) - collider.max.z - 0.0001f;
			}
			else
			{
				position.z = Maths::Floor(position.z + collider.min.z) - collider.min.z + 0.0001f;
			}

			collided = true;
		}
		else if (thing.hasCollisionFlags(CollisionFlag::MapEdge) && collider.intersectsMapEdge(zPosition))
		{
			if (velocity.z > 0)
			{
				position.z = Map::getMap().dimensions.z - collider.max.z - 0.0001f;
			}
			else
			{
				position.z = -collider.min.z;
			}

			collided = true;
		}
	}

	if (collided)
	{
		velocity.z = 0;
	}
	else
	{
		position.z += velocity.z;
	}

	return collided;
}

shared bool CollisionY(ICollision@ thing, Vec3f &inout position, Vec3f &inout velocity)
{
	bool collided = false;

	if (thing.hasCollider())
	{
		AABB@ collider = thing.getCollider();
		Vec3f yPosition = position + Vec3f(0, velocity.y, 0);

		if (thing.hasCollisionFlags(CollisionFlag::Blocks) && velocity.y != 0 && collider.intersectsNewSolid(position, yPosition))
		{
			Vec3f min = (position + collider.min).floor();
			Vec3f max = (position + collider.max).ceil();

			if (velocity.y > 0)
			{
				position.y = max.y - collider.max.y - 0.0001f;
			}
			else
			{
				position.y = min.y - collider.min.y + 0.0001f;
			}

			collided = true;
		}
	}

	if (collided)
	{
		velocity.y = 0;
	}
	else
	{
		position.y += velocity.y;
	}

	return collided;
}
