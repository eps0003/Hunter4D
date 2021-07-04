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

	Vec3f gravity;

	private SColor _color = color_white;

	AABB@ collider = AABB(Vec3f(-0.3f, -1.6f, -0.3f), Vec3f(0.3f, 0.1f, 0.3f));
	private u8 collisionFlags = 0;
	private Map@ map = Map::getMap();

	private bool collisionX = false;
	private bool collisionY = false;
	private bool collisionZ = false;

	SColor color
	{
		get const
		{
			return _color;
		}
		set
		{
			_color = value;

			if (!isClient())
			{
				CBitStream bs;
				bs.write_u16(id);
				bs.write_u32(value.color);
				getRules().SendCommand(getRules().getCommandID("set object color"), bs, true);
			}
		}
	}

	Object(Vec3f position)
	{
		this.position = position;
		AssignUniqueID();
	}

	void opAssign(Object object)
	{
		oldPosition = position;
		position = object.position;
		oldVelocity = velocity;
		velocity = object.velocity;
	}

	void AssignUniqueID()
	{
		if (isServer())
		{
			id = getRules().add_u32("object id", 1);
		}
	}

	void SerializeInit(CBitStream@ bs)
	{
		bs.write_u16(id);
		position.Serialize(bs);
		velocity.Serialize(bs);
		bs.write_u8(collisionFlags);
		bs.write_u32(color.color);
		gravity.Serialize(bs);
	}

	void SerializeTick(CBitStream@ bs)
	{
		bs.write_u16(id);
		position.Serialize(bs);
		velocity.Serialize(bs);
	}

	void DeserializeInit(CBitStream@ bs)
	{
		id = bs.read_u16();
		position = Vec3f(bs);
		oldPosition = position;
		velocity = Vec3f(bs);
		oldVelocity = velocity;
		collisionFlags = bs.read_u8();
		color = SColor(bs.read_u32());
		gravity = Vec3f(bs);
	}

	void DeserializeTick(CBitStream@ bs)
	{
		id = bs.read_u16();
		position = Vec3f(bs);
		velocity = Vec3f(bs);
	}

	void HandleSerializeInit(CPlayer@ player)
	{
		// Sync to player if server not localhost
		if (isClient()) return;

		CBitStream bs;
		SerializeInit(bs);

		if (player !is null)
		{
			getRules().SendCommand(getRules().getCommandID("init object"), bs, player);
		}
		else
		{
			getRules().SendCommand(getRules().getCommandID("init object"), bs, true);
		}
	}

	void HandleSerializeTick()
	{
		// Sync to players if server not localhost
		if (isClient()) return;

		CBitStream bs;
		SerializeTick(bs);
		getRules().SendCommand(getRules().getCommandID("sync object"), bs, true);
	}

	void HandleDeserializeInit(CBitStream@ bs)
	{
		// Deserialize if client not localhost
		if (isServer()) return;

		DeserializeInit(bs);
		Object::AddObject(this);
	}

	void HandleDeserializeTick(CBitStream@ bs)
	{
		// Deserialize if client not localhost
		if (isServer()) return;

		DeserializeTick(bs);

		Object@ oldObject = Object::getObject(id);
		if (oldObject !is null)
		{
			oldObject = this;
		}
	}

	void PreUpdate()
	{
		oldPosition = position;
		oldVelocity = velocity;

		// Reset velocity from collision last tick
		if (doPhysicsUpdate())
		{
			if (collisionX)
			{
				velocity.x = 0;
				collisionX = false;
			}

			if (collisionY)
			{
				velocity.y = 0;
				collisionY = false;
			}

			if (collisionZ)
			{
				velocity.z = 0;
				collisionZ = false;
			}
		}
	}

	void Update()
	{
		if (doPhysicsUpdate())
		{
			velocity += gravity;
		}
	}

	void PostUpdate()
	{
		if (doPhysicsUpdate())
		{
			velocity.y = Maths::Clamp(velocity.y, -1, 1);

			//set velocity to zero if low enough
			if (Maths::Abs(velocity.x) < 0.001f) velocity.x = 0;
			if (Maths::Abs(velocity.y) < 0.001f) velocity.y = 0;
			if (Maths::Abs(velocity.z) < 0.001f) velocity.z = 0;

			Collision();
		}
	}

	bool doPhysicsUpdate()
	{
		return isServer();
	}

	void SetCollisionFlags(u8 flags)
	{
		collisionFlags = flags;
	}

	bool hasCollisionFlags(u8 flags)
	{
		return (collisionFlags & flags) == flags;
	}

	void Collision()
	{
		if (collider is null) return;

		bool collideBlocks = hasCollisionFlags(CollisionFlag::Blocks);
		bool collideMapEdge = hasCollisionFlags(CollisionFlag::MapEdge);

		if (velocity.x != 0) CollisionX(collideBlocks, collideMapEdge);
		if (velocity.z != 0) CollisionZ(collideBlocks, collideMapEdge);
		if (velocity.y != 0) CollisionY(collideBlocks);
	}

	void CollisionX(bool blocks, bool mapEdge)
	{
		Vec3f xPosition = position + Vec3f(velocity.x, 0, 0);

		if (blocks && collider.intersectsNewSolid(position, xPosition))
		{
			Vec3f min = (position + collider.min).floor();
			Vec3f max = (position + collider.max).ceil();

			if (velocity.x > 0)
			{
				position.x = max.x - collider.max.x - 0.0001f;
			}
			else
			{
				position.x = min.x - collider.min.x + 0.0001f;
			}

			collisionX = true;
		}
		else if (mapEdge && collider.intersectsMapEdge(xPosition))
		{
			if (velocity.x > 0)
			{
				position.x = map.dimensions.x - collider.max.x - 0.0001f;
			}
			else
			{
				position.x = -collider.min.x;
			}

			collisionX = true;
		}
		else
		{
			collisionX = false;
			position.x += velocity.x;
		}
	}

	void CollisionZ(bool blocks, bool mapEdge)
	{
		Vec3f zPosition = position + Vec3f(0, 0, velocity.z);

		if (blocks && collider.intersectsNewSolid(position, zPosition))
		{
			Vec3f min = (position + collider.min).floor();
			Vec3f max = (position + collider.max).ceil();

			if (velocity.z > 0)
			{
				position.z = max.z - collider.max.z - 0.0001f;
			}
			else
			{
				position.z = min.z - collider.min.z + 0.0001f;
			}

			collisionZ = true;
		}
		else if (mapEdge && collider.intersectsMapEdge(zPosition))
		{
			if (velocity.z > 0)
			{
				position.z = map.dimensions.z - collider.max.z - 0.0001f;
			}
			else
			{
				position.z = -collider.min.z;
			}

			collisionZ = true;
		}
		else
		{
			collisionZ = false;
			position.z += velocity.z;
		}
	}

	void CollisionY(bool blocks)
	{
		Vec3f yPosition = position + Vec3f(0, velocity.y, 0);

		if (blocks && collider.intersectsNewSolid(position, yPosition))
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

			collisionY = true;
		}
		else
		{
			position.y += velocity.y;
		}
	}

	void Render()
	{
		float[] matrix;
		Matrix::MakeIdentity(matrix);
		Matrix::SetTranslation(matrix, interPosition.x, interPosition.y, interPosition.z);
		Render::SetModelTransform(matrix);

		Vec3f min = collider.min;
		Vec3f max = collider.max;

		Vertex[] vertices = {
			// Left
			Vertex(min.x, max.y, max.z, 0, 0, color),
			Vertex(min.x, max.y, min.z, 1, 0, color),
			Vertex(min.x, min.y, min.z, 1, 1, color),
			Vertex(min.x, min.y, max.z, 0, 1, color),
			// Right
			Vertex(max.x, max.y, min.z, 0, 0, color),
			Vertex(max.x, max.y, max.z, 1, 0, color),
			Vertex(max.x, min.y, max.z, 1, 1, color),
			Vertex(max.x, min.y, min.z, 0, 1, color),
			// Front
			Vertex(min.x, max.y, min.z, 0, 0, color),
			Vertex(max.x, max.y, min.z, 1, 0, color),
			Vertex(max.x, min.y, min.z, 1, 1, color),
			Vertex(min.x, min.y, min.z, 0, 1, color),
			// Back
			Vertex(max.x, max.y, max.z, 0, 0, color),
			Vertex(min.x, max.y, max.z, 1, 0, color),
			Vertex(min.x, min.y, max.z, 1, 1, color),
			Vertex(max.x, min.y, max.z, 0, 1, color),
			// Down
			Vertex(max.x, min.y, max.z, 0, 0, color),
			Vertex(min.x, min.y, max.z, 1, 0, color),
			Vertex(min.x, min.y, min.z, 1, 1, color),
			Vertex(max.x, min.y, min.z, 0, 1, color),
			// Up
			Vertex(min.x, max.y, max.z, 0, 0, color),
			Vertex(max.x, max.y, max.z, 1, 0, color),
			Vertex(max.x, max.y, min.z, 1, 1, color),
			Vertex(min.x, max.y, min.z, 0, 1, color)
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
		interPosition = oldPosition.lerp(oldPosition + velocity, t);
		interPosition = interPosition.clamp(oldPosition, position);
		interVelocity = oldVelocity.lerp(velocity, t);
	}

	bool isVisible()
	{
		return true;
	}

	void OnRemove()
	{
		print("Removed object: " + id);
	}
}
