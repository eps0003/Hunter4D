#include "ObjectCommon.as"
#include "Collision.as"

class Object : ICollision
{
	private u16 id = 0;

	bool hasSyncedInit = false;

	private Vec3f gravity;
	private float friction = 1.0f;

	Vec3f position;
	private Vec3f oldPosition;
	Vec3f interPosition;

	Vec3f velocity;

	private AABB@ collider;
	private u8 collisionFlags = 0;

	private uint lastUpdate = 0;

	private float[] matrix;

	private CRules@ rules = getRules();

	Object()
	{
		Matrix::MakeIdentity(matrix);
	}

	Object(Vec3f position)
	{
		this.position = position;
		oldPosition = position;
		id = rules.add_u32("id", 1);
	}

	void opAssign(Object object)
	{
		oldPosition = position;

		position = object.position;
		velocity = object.velocity;

		lastUpdate = getGameTime();
	}

	u16 getID()
	{
		return id;
	}

	AABB@ getCollider()
	{
		return collider;
	}

	void SetCollider(AABB@ collider)
	{
		@this.collider = collider;
	}

	bool hasCollider()
	{
		return collider !is null;
	}

	void AddCollisionFlags(u8 flags)
	{
		SetCollisionFlags(collisionFlags | flags);
	}

	void RemoveCollisionFlags(u8 flags)
	{
		SetCollisionFlags(collisionFlags & ~flags);
	}

	void SetCollisionFlags(u8 flags)
	{
		collisionFlags = flags;

		if (!isClient() && hasSyncedInit)
		{
			CBitStream bs;
			bs.write_u16(id);
			bs.write_u8(collisionFlags);
			rules.SendCommand(rules.getCommandID("set object collision flags"), bs, true);
		}
	}

	bool hasCollisionFlags(u8 flags)
	{
		return (collisionFlags & flags) == flags;
	}

	Vec3f getGravity()
	{
		return gravity;
	}

	void SetGravity(Vec3f gravity)
	{
		this.gravity = gravity;

		if (!isClient() && hasSyncedInit)
		{
			CBitStream bs;
			bs.write_u16(id);
			gravity.Serialize(bs);
			rules.SendCommand(rules.getCommandID("set object gravity"), bs, true);
		}
	}

	float getFriction()
	{
		return friction;
	}

	void SetFriction(float friction)
	{
		this.friction = friction;

		if (!isClient() && hasSyncedInit)
		{
			CBitStream bs;
			bs.write_u16(id);
			bs.write_f32(friction);
			rules.SendCommand(rules.getCommandID("set object friction"), bs, true);
		}
	}

	void SerializeInit(CPlayer@ player = null, CBitStream@ bs = CBitStream(), string commandName = "init object")
	{
		bs.write_u16(id);
		position.Serialize(bs);
		velocity.Serialize(bs);
		gravity.Serialize(bs);
		bs.write_u8(collisionFlags);

		bs.write_bool(hasCollider());
		if (hasCollider())
		{
			collider.Serialize(bs);
		}

		hasSyncedInit = true;

		if (player !is null)
		{
			rules.SendCommand(rules.getCommandID(commandName), bs, player);
		}
		else
		{
			rules.SendCommand(rules.getCommandID(commandName), bs, true);
		}
	}

	void SerializeTick(CBitStream@ bs = CBitStream(), string commandName = "sync object")
	{
		bs.write_u16(id);
		position.Serialize(bs);
		velocity.Serialize(bs);

		rules.SendCommand(rules.getCommandID(commandName), bs, true);
	}

	void SerializeRemove(CBitStream@ bs = CBitStream(), string commandName = "remove object")
	{
		bs.write_u16(id);

		rules.SendCommand(rules.getCommandID(commandName), bs, true);
	}

	void DeserializeInit(CBitStream@ bs)
	{
		if (!bs.saferead_u16(id)) return;
		if (!position.deserialize(bs)) return;
		if (!velocity.deserialize(bs)) return;
		if (!gravity.deserialize(bs)) return;
		if (!bs.saferead_u8(collisionFlags)) return;

		bool hasCollider;
		if (!bs.saferead_bool(hasCollider)) return;

		if (hasCollider)
		{
			@collider = AABB();
			if (!collider.deserialize(bs)) return;
		}

		hasSyncedInit = true;

		Object::AddObject(this);
	}

	void DeserializeTick(CBitStream@ bs)
	{
		if (!bs.saferead_u16(id)) return;
		if (!position.deserialize(bs)) return;
		if (!velocity.deserialize(bs)) return;

		// Update object
		Object@ oldObject = Object::getObject(id);
		if (oldObject !is null)
		{
			oldObject = this;
		}
	}

	void DeserializeRemove(CBitStream@ bs)
	{
		if (!bs.saferead_u16(id)) return;

		Object::RemoveObject(id);
	}

	void PreUpdate()
	{
		if (isServer() || getGameTime() > lastUpdate + 1)
		{
			oldPosition = position;
		}
	}

	void Update()
	{
		if (isServer())
		{
			velocity += gravity;
		}
	}

	void PostUpdate()
	{
		if (isServer())
		{
			if (isOnGround())
			{
				velocity.x *= friction;
				velocity.z *= friction;
			}

			velocity.y = Maths::Clamp(velocity.y, -1, 1);

			//set velocity to zero if low enough
			if (Maths::Abs(velocity.x) < 0.001f) velocity.x = 0;
			if (Maths::Abs(velocity.y) < 0.001f) velocity.y = 0;
			if (Maths::Abs(velocity.z) < 0.001f) velocity.z = 0;

			Collision();
		}
	}

	void Collision()
	{
		if (hasCollider())
		{
			CollisionX(this, position, velocity);
			CollisionZ(this, position, velocity);
			CollisionY(this, position, velocity);
		}
		else
		{
			position += velocity;
		}
	}

	void Render()
	{
		Matrix::SetTranslation(matrix, interPosition.x, interPosition.y, interPosition.z);
		Render::SetModelTransform(matrix);

		Vec3f min = collider.min;
		Vec3f max = collider.max;
		SColor color = color_white;

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

	void Interpolate()
	{
		float t = Interpolation::getFrameTime();
		interPosition = oldPosition.lerp(position, t);
		// interPosition = oldPosition.lerp(oldPosition + velocity, t);
		// interPosition = interPosition.clamp(oldPosition, position);
	}

	bool isVisible()
	{
		return hasCollider();
	}

	bool isOnGround()
	{
		return hasCollider() && collider.intersectsNewSolid(position, position + Vec3f(0, -0.001f, 0));
	}

	void OnInit()
	{
		print("Added object: " + id);
	}

	void OnRemove()
	{
		print("Removed object: " + id);
	}
}
