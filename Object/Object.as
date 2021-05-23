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

	AABB@ bounds = AABB(Vec3f(-0.5f, -1.0f, -0.5f), Vec3f(0.5f, 0.0f, 0.5f));
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

		if (bounds !is null)
		{
			bool collideBlocks = hasCollisionFlags(CollisionFlag::Blocks);
			bool collideMapEdge = hasCollisionFlags(CollisionFlag::MapEdge);
			Vec3f mapDim = Map::getMap().dimensions;

			Vec3f min = (position + bounds.min).floor();
			Vec3f max = (position + bounds.max).ceil();

			// x collision
			if (velocity.x != 0)
			{
				Vec3f xPosition = position + Vec3f(velocity.x, 0, 0);

				if (collideBlocks && bounds.intersectsNewSolid(position, xPosition))
				{
					if (velocity.x > 0)
					{
						position.x = max.x - bounds.max.x;
					}
					else
					{
						position.x = min.x - bounds.min.x;
					}

					collisionX = true;
				}
				else if (collideMapEdge && bounds.intersectsMapEdge(xPosition))
				{
					if (velocity.x > 0)
					{
						position.x = mapDim.x - bounds.max.x;
					}
					else
					{
						position.x = -bounds.min.x;
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

				if (collideBlocks && bounds.intersectsNewSolid(position, zPosition))
				{
					if (velocity.z > 0)
					{
						position.z = max.z - bounds.max.z;
					}
					else
					{
						position.z = min.z - bounds.min.z;
					}

					collisionZ = true;
				}
				else if (collideMapEdge && bounds.intersectsMapEdge(zPosition))
				{
					if (velocity.z > 0)
					{
						position.z = mapDim.z - bounds.max.z;
					}
					else
					{
						position.z = -bounds.min.z;
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

				if (collideBlocks && bounds.intersectsNewSolid(position, yPosition))
				{
					if (velocity.y > 0)
					{
						position.y = max.y - bounds.max.y;
					}
					else
					{
						position.y = min.y - bounds.min.y;
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

		Vertex[] vertices = {
			Vertex(-1,  1, 0, 0, 0, color_white),
			Vertex( 1,  1, 0, 1, 0, color_white),
			Vertex( 1, -1, 0, 1, 1, color_white),
			Vertex(-1, -1, 0, 0, 1, color_white)
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
