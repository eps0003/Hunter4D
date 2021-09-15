#include "ObjectCommon.as"
#include "Collision.as"
#include "Camera.as"

shared class Object : ICollision
{
	private u16 id = 0;
	private string name;

	private string initCommand = "init object";
	private string syncCommand = "sync object";
	private string removeCommand = "remove object";

	bool hasSyncedInit = false;

	private Vec3f gravity;
	private float scale = 1.0f;
	private float friction = 1.0f;
	private float elasticity = 0.0f;

	Vec3f position;
	private Vec3f oldPosition;
	Vec3f interPosition;

	Vec3f rotation;
	private Vec3f oldRotation;
	Vec3f interRotation;

	Vec3f velocity;
	private Vec3f oldVelocity;
	Vec3f interVelocity;

	private AABB@ collider;
	private u8 collisionFlags = 0;

	private uint lastUpdate = 0;
	private uint spawnTime = 0;

	private float cullRadius = 3.0f;

	private float[] matrix;

	private CRules@ rules = getRules();
	private Camera@ camera;

	Object(string name, Vec3f position, Vec3f rotation = Vec3f(), float scale = 1.0f)
	{
		this.name = name;
		this.position = position;
		this.rotation = rotation;
		this.scale = scale;

		oldPosition = position;
		oldRotation = rotation;

		id = rules.add_u32("id", 1);
		spawnTime = getGameTime();
	}

	void opAssign(Object object)
	{
		oldPosition = position;
		oldRotation = rotation;
		oldVelocity = velocity;

		position = object.position;
		rotation = object.rotation;
		velocity = object.velocity;

		lastUpdate = getGameTime();
	}

	u16 getID()
	{
		return id;
	}

	string getName()
	{
		return name;
	}

	void SetName(string name)
	{
		this.name = name;

		if (!isClient() && hasSyncedInit)
		{
			CBitStream bs;
			bs.write_u16(id);
			bs.write_string(name);
			rules.SendCommand(rules.getCommandID("set object name"), bs, true);
		}
	}

	uint getSpawnTime()
	{
		return spawnTime;
	}

	void SetInitCommand(string cmd)
	{
		initCommand = cmd;
	}

	void SetSyncCommand(string cmd)
	{
		syncCommand = cmd;
	}

	void SetRemoveCommand(string cmd)
	{
		removeCommand = cmd;
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

	bool isOnGround()
	{
		return (
			hasCollider() &&
			hasCollisionFlags(CollisionFlag::Blocks) &&
			collider.intersectsNewSolid(position, position + Vec3f(0, -0.001f, 0))
		);
	}

	Vec3f getGravity()
	{
		return gravity;
	}

	void SetGravity(Vec3f gravity)
	{
		if (this.gravity == gravity) return;

		this.gravity = gravity;

		if (!isClient() && hasSyncedInit)
		{
			CBitStream bs;
			bs.write_u16(id);
			gravity.Serialize(bs);
			rules.SendCommand(rules.getCommandID("set object gravity"), bs, true);
		}
	}

	float getScale()
	{
		return scale;
	}

	float getFriction()
	{
		return friction;
	}

	void SetFriction(float friction)
	{
		if (this.friction == friction) return;

		this.friction = friction;

		if (!isClient() && hasSyncedInit)
		{
			CBitStream bs;
			bs.write_u16(id);
			bs.write_f32(friction);
			rules.SendCommand(rules.getCommandID("set object friction"), bs, true);
		}
	}

	float getElasticity()
	{
		return elasticity;
	}

	void SetElasticity(float elasticity)
	{
		if (this.elasticity == elasticity) return;

		this.elasticity = elasticity;

		if (!isClient() && hasSyncedInit)
		{
			CBitStream bs;
			bs.write_u16(id);
			bs.write_f32(elasticity);
			rules.SendCommand(rules.getCommandID("set object elasticity"), bs, true);
		}
	}

	void SetCullRadius(float radius)
	{
		cullRadius = radius;
	}

	Vec3f getCenter()
	{
		return hasCollider() ? interPosition + collider.center : interPosition;
	}

	void SerializeInit(CPlayer@ player = null, CBitStream@ bs = CBitStream())
	{
		bs.write_u16(id);
		bs.write_string(name);
		position.Serialize(bs);
		rotation.Serialize(bs);
		velocity.Serialize(bs);
		gravity.Serialize(bs);
		bs.write_f32(scale);
		bs.write_f32(friction);
		bs.write_u8(collisionFlags);

		bs.write_bool(hasCollider());
		if (hasCollider())
		{
			collider.Serialize(bs);
		}

		hasSyncedInit = true;

		if (player !is null)
		{
			rules.SendCommand(rules.getCommandID(initCommand), bs, player);
		}
		else
		{
			rules.SendCommand(rules.getCommandID(initCommand), bs, true);
		}
	}

	void SerializeTick(CBitStream@ bs = CBitStream())
	{
		bs.write_u16(id);
		position.Serialize(bs);
		rotation.Serialize(bs);
		velocity.Serialize(bs);

		rules.SendCommand(rules.getCommandID(syncCommand), bs, true);
	}

	void SerializeRemove(CBitStream@ bs = CBitStream())
	{
		bs.write_u16(id);

		rules.SendCommand(rules.getCommandID(removeCommand), bs, true);
	}

	void DeserializeInit(CBitStream@ bs)
	{
		if (!bs.saferead_u16(id)) return;
		if (!bs.saferead_string(name)) return;
		if (!position.deserialize(bs)) return;
		if (!rotation.deserialize(bs)) return;
		if (!velocity.deserialize(bs)) return;
		if (!gravity.deserialize(bs)) return;
		if (!bs.saferead_f32(scale)) return;
		if (!bs.saferead_f32(friction)) return;
		if (!bs.saferead_u8(collisionFlags)) return;

		bool hasCollider;
		if (!bs.saferead_bool(hasCollider)) return;

		if (hasCollider)
		{
			@collider = AABB();
			if (!collider.deserialize(bs)) return;
		}

		hasSyncedInit = true;
	}

	void DeserializeTick(CBitStream@ bs)
	{
		if (!bs.saferead_u16(id)) return;
		if (!position.deserialize(bs)) return;
		if (!rotation.deserialize(bs)) return;
		if (!velocity.deserialize(bs)) return;
	}

	void DeserializeRemove(CBitStream@ bs)
	{
		if (!bs.saferead_u16(id)) return;
	}

	void PreUpdate()
	{
		if (isServer() || getGameTime() > lastUpdate + 1)
		{
			oldPosition = position;
			oldRotation = rotation;
			oldVelocity = velocity;
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

			Collision();

			//set velocity to zero if low enough
			if (Maths::Abs(velocity.x) < 0.001f) velocity.x = 0;
			if (Maths::Abs(velocity.y) < 0.001f) velocity.y = 0;
			if (Maths::Abs(velocity.z) < 0.001f) velocity.z = 0;
		}
	}

	void Collision()
	{
		if (hasCollider())
		{
			Vec3f tempVel = velocity;
			if (CollisionX(this, position, tempVel)) velocity.x *= -elasticity;
			if (CollisionZ(this, position, tempVel)) velocity.z *= -elasticity;
			if (CollisionY(this, position, tempVel)) velocity.y *= -elasticity;
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
		interRotation = oldRotation.lerp(rotation, t);
		interVelocity = oldVelocity.lerp(velocity, t);
	}

	bool isVisible()
	{
		return (
			hasCollider() &&
			camera.getFrustum().containsSphere(getCenter() - camera.interPosition, cullRadius * scale)
		);
	}

	void OnInit()
	{
		print("Added object: " + name);

		if (isClient())
		{
			Matrix::MakeIdentity(matrix);

			@camera = Camera::getCamera();
		}
	}

	void OnRemove()
	{
		print("Removed object: " + name);
	}
}
