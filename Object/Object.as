#include "ObjectCommon.as"
#include "Vec3f.as"
#include "Camera.as"
#include "IBounds.as"
#include "Map.as"

class Object
{
	u16 id = 0;

	Vec3f position;
	Vec3f oldPosition;
	Vec3f interPosition;

	Vec3f velocity;
	Vec3f oldVelocity;
	Vec3f interVelocity;

	AABB@ collider = AABB(Vec3f(-0.5f, -1.0f, -0.5f), Vec3f(0.5f, 0.0f, 0.5f));
	private uint collisionFlags = 0;

	private bool collisionX = false;
	private bool collisionY = false;
	private bool collisionZ = false;

	Object(Vec3f position)
	{
		this.position = position;
	}

	Object(CBitStream@ bs)
	{
		id = bs.read_u16();
		position = Vec3f(bs);
		oldPosition = position;
		velocity = Vec3f(bs);
		oldVelocity = velocity;
	}

	void opAssign(Object object)
	{
		oldPosition = position;
		position = object.position;
		oldVelocity = velocity;
		velocity = object.velocity;
	}

	void SerializeInit(CBitStream@ bs)
	{
		bs.write_u16(id);
		position.Serialize(bs);
		velocity.Serialize(bs);
	}

	void SerializeTick(CBitStream@ bs)
	{
		bs.write_u16(id);
		position.Serialize(bs);
		velocity.Serialize(bs);
	}

	void Update()
	{
		oldPosition = position;
		oldVelocity = velocity;

		// Reset velocity from collision last tick
		if (collisionX) velocity.x = 0;
		if (collisionY) velocity.y = 0;
		if (collisionZ) velocity.z = 0;

		Collision();
	}

	void SetCollisionFlags(u8 flags)
	{
		collisionFlags = flags;
	}

	private bool hasCollisionFlags(u8 flags)
	{
		return (collisionFlags & flags) == flags;
	}

	void Collision()
	{
		// Reset collisions
		collisionX = false;
		collisionY = false;
		collisionZ = false;

		if (collider !is null)
		{
			bool collideBlocks = hasCollisionFlags(CollisionFlag::Blocks);
			bool collideMapEdge = hasCollisionFlags(CollisionFlag::MapEdge);
			Vec3f mapDim = Map::getMap().dimensions;

			Vec3f min = (position + collider.min).floor();
			Vec3f max = (position + collider.max).ceil();

			// x collision
			if (velocity.x != 0)
			{
				Vec3f xPosition = position + Vec3f(velocity.x, 0, 0);

				if (collideBlocks && collider.intersectsNewSolid(position, xPosition))
				{
					if (velocity.x > 0)
					{
						position.x = max.x - collider.max.x;
					}
					else
					{
						position.x = min.x - collider.min.x;
					}

					collisionX = true;
				}
				else if (collideMapEdge && collider.intersectsMapEdge(xPosition))
				{
					if (velocity.x > 0)
					{
						position.x = mapDim.x - collider.max.x;
					}
					else
					{
						position.x = -collider.min.x;
					}

					collisionX = true;

					if (position.x == oldPosition.x)
					{
						velocity.x = 0;
					}
				}
			}

			// z collision
			if (velocity.z != 0)
			{
				Vec3f zPosition = position + Vec3f(0, 0, velocity.z);

				if (collideBlocks && collider.intersectsNewSolid(position, zPosition))
				{
					if (velocity.z > 0)
					{
						position.z = max.z - collider.max.z;
					}
					else
					{
						position.z = min.z - collider.min.z;
					}

					collisionZ = true;
				}
				else if (collideMapEdge && collider.intersectsMapEdge(zPosition))
				{
					if (velocity.z > 0)
					{
						position.z = mapDim.z - collider.max.z;
					}
					else
					{
						position.z = -collider.min.z;
					}

					collisionZ = true;

					if (position.z == oldPosition.z)
					{
						velocity.z = 0;
					}
				}
			}

			// y collision
			if (velocity.y != 0)
			{
				Vec3f yPosition = position + Vec3f(0, velocity.y, 0);

				if (collideBlocks && collider.intersectsNewSolid(position, yPosition))
				{
					if (velocity.y > 0)
					{
						position.y = max.y - collider.max.y;
					}
					else
					{
						position.y = min.y - collider.min.y;
					}

					collisionY = true;

					if (position.y == oldPosition.y)
					{
						velocity.y = 0;
					}
				}
			}
		}

		if (!collisionX) position.x += velocity.x;
		if (!collisionY) position.y += velocity.y;
		if (!collisionZ) position.z += velocity.z;
	}

	void Render()
	{
		float[] matrix;
		Matrix::MakeIdentity(matrix);
		Matrix::SetTranslation(matrix, interPosition.x, interPosition.y, interPosition.z);
		Render::SetModelTransform(matrix);

		Vec3f min = collider.min;
		Vec3f max = collider.max;
		SColor col = color_white;

		Vertex[] vertices = {
			// Left
			Vertex(min.x, max.y, max.z, 0, 0, col),
			Vertex(min.x, max.y, min.z, 1, 0, col),
			Vertex(min.x, min.y, min.z, 1, 1, col),
			Vertex(min.x, min.y, max.z, 0, 1, col),
			// Right
			Vertex(max.x, max.y, min.z, 0, 0, col),
			Vertex(max.x, max.y, max.z, 1, 0, col),
			Vertex(max.x, min.y, max.z, 1, 1, col),
			Vertex(max.x, min.y, min.z, 0, 1, col),
			// Front
			Vertex(min.x, max.y, min.z, 0, 0, col),
			Vertex(max.x, max.y, min.z, 1, 0, col),
			Vertex(max.x, min.y, min.z, 1, 1, col),
			Vertex(min.x, min.y, min.z, 0, 1, col),
			// Back
			Vertex(max.x, max.y, max.z, 0, 0, col),
			Vertex(min.x, max.y, max.z, 1, 0, col),
			Vertex(min.x, min.y, max.z, 1, 1, col),
			Vertex(max.x, min.y, max.z, 0, 1, col),
			// Down
			Vertex(max.x, min.y, max.z, 0, 0, col),
			Vertex(min.x, min.y, max.z, 1, 0, col),
			Vertex(min.x, min.y, min.z, 1, 1, col),
			Vertex(max.x, min.y, min.z, 0, 1, col),
			// Up
			Vertex(min.x, max.y, max.z, 0, 0, col),
			Vertex(max.x, max.y, max.z, 1, 0, col),
			Vertex(max.x, max.y, min.z, 1, 1, col),
			Vertex(min.x, max.y, min.z, 0, 1, col)
		};

		Render::SetBackfaceCull(false);
		Render::SetAlphaBlend(true);
		Render::RawQuads("pixel", vertices);
		Render::SetAlphaBlend(false);
		Render::SetBackfaceCull(true);
	}

	void RenderHUD()
	{
		GUI::DrawText("Position: " + position.toString(), Vec2f(10, 10), color_black);
	}

	void Interpolate()
	{
		float t = Interpolation::getFrameTime();

		if (oldPosition != position)
		{
			interPosition = oldPosition.lerp(oldPosition + velocity, t);
			interPosition = interPosition.clamp(oldPosition, position);
		}

		if (oldVelocity != velocity)
		{
			interVelocity = oldVelocity.lerp(velocity, t);
		}
	}
}
