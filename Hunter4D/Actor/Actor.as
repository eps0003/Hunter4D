#include "ActorCommon.as"
#include "Mouse.as"
#include "Collision.as"
#include "ModelSegment.as"
#include "ActorModel.as"

shared class Actor : ICollision
{
	private u16 id = 0;
	private CPlayer@ player;

	private string initCommand = "init actor";
	private string syncCommand = "sync actor";
	private string removeCommand = "remove actor";

	bool hasSyncedInit = false;

	private Vec3f gravity;
	private float scale = 1.0f;

	Vec3f position;
	private Vec3f oldPosition;
	Vec3f interPosition;

	Vec3f rotation;
	private Vec3f oldRotation;
	Vec3f interRotation;

	Vec3f velocity;
	private Vec3f oldVelocity;
	Vec3f interVelocity;

	private u8 health = 255;

	private AABB@ collider;
	private u8 collisionFlags = 0;

	private uint lastUpdate = 0;
	private uint spawnTime = 0;

	private float cullRadius = 3.0f;

	float cameraHeight = 1.6f;

	private CRules@ rules = getRules();
	private Map@ map = Map::getMap();
	private Driver@ driver;
	private CControls@ controls;
	private Camera@ camera;
	private Mouse@ mouse;

	Actor(CPlayer@ player, Vec3f position, Vec3f rotation = Vec3f(), float scale = 1.0f)
	{
		@this.player = player;

		this.position = position;
		this.rotation = rotation;
		this.scale = scale;

		oldPosition = position;
		oldRotation = rotation;

		id = rules.add_u32("id", 1);
		spawnTime = getGameTime();
	}

	void opAssign(Actor actor)
	{
		oldPosition = position;
		oldRotation = rotation;
		oldVelocity = velocity;

		position = actor.position;
		rotation = actor.rotation;
		velocity = actor.velocity;

		lastUpdate = getGameTime();
	}

	u16 getID()
	{
		return id;
	}

	string getName()
	{
		return player.getUsername();
	}

	uint getSpawnTime()
	{
		return spawnTime;
	}

	CPlayer@ getPlayer()
	{
		return player;
	}

	CBlob@ getBlob()
	{
		return player.getBlob();
	}

	bool isMyActor()
	{
		return player.isMyPlayer();
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

	void SetVelocity(Vec3f velocity)
	{
		if (isClient())
		{
			this.velocity = velocity;
		}
		else
		{
			CBitStream bs;
			velocity.Serialize(bs);
			rules.SendCommand(rules.getCommandID("set actor velocity"), bs, player);
		}
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
		if (collisionFlags == flags) return;

		collisionFlags = flags;

		if (!isClient() && hasSyncedInit)
		{
			CBitStream bs;
			bs.write_u16(id);
			bs.write_u8(collisionFlags);
			rules.SendCommand(rules.getCommandID("set actor collision flags"), bs, true);
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
			rules.SendCommand(rules.getCommandID("set actor gravity"), bs, true);
		}
	}

	float getScale()
	{
		return scale;
	}

	void SetHealth(u8 health)
	{
		if (this.health == health) return;

		this.health = health;

		if (!isClient() && hasSyncedInit)
		{
			CBitStream bs;
			bs.write_u16(id);
			bs.write_u8(health);
			rules.SendCommand(rules.getCommandID("set actor health"), bs, true);
		}
	}

	u8 getHealth()
	{
		return health;
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
		bs.write_netid(this.player.getNetworkID());
		bs.write_u16(id);
		position.Serialize(bs);
		rotation.Serialize(bs);
		velocity.Serialize(bs);
		gravity.Serialize(bs);
		bs.write_f32(scale);
		bs.write_u8(collisionFlags);
		bs.write_u8(health);

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
		rules.SendCommand(rules.getCommandID(removeCommand), bs, true);
	}

	bool deserializeInit(CBitStream@ bs)
	{
		if (!saferead_player(bs, @player)) return false;
		if (!bs.saferead_u16(id)) return false;
		if (!position.deserialize(bs)) return false;
		if (!rotation.deserialize(bs)) return false;
		if (!velocity.deserialize(bs)) return false;
		if (!gravity.deserialize(bs)) return false;
		if (!bs.saferead_f32(scale)) return false;
		if (!bs.saferead_u8(collisionFlags)) return false;
		if (!bs.saferead_u8(health)) return false;

		bool hasCollider;
		if (!bs.saferead_bool(hasCollider)) return false;

		if (hasCollider)
		{
			@collider = AABB();
			if (!collider.deserialize(bs)) return false;
		}

		hasSyncedInit = true;
		return true;
	}

	bool deserializeTick(CBitStream@ bs)
	{
		if (!bs.saferead_u16(id)) return false;
		if (!position.deserialize(bs)) return false;
		if (!rotation.deserialize(bs)) return false;
		if (!velocity.deserialize(bs)) return false;

		return true;
	}

	bool deserializeRemove(CBitStream@ bs)
	{
		// This can include extra data like who killed the object
		// to know whether to display something to the client
		return true;
	}

	u8 getTeamNum()
	{
		return player.getTeamNum();
	}

	void SetTeamNum(u8 team)
	{
		player.server_setTeamNum(team);
	}

	void PreUpdate()
	{
		if (isMyActor() || getGameTime() > lastUpdate + 1)
		{
			oldPosition = position;
			oldRotation = rotation;
			oldVelocity = velocity;
		}
	}

	void Update()
	{
		if (isMyActor())
		{
			velocity += gravity;

			rotation += Vec3f(mouse.velocity.y, mouse.velocity.x, 0);
			rotation.x = Maths::Clamp(rotation.x, -90, 90);
			rotation.z = Maths::Clamp(rotation.z, -90, 90);
		}
	}

	void PostUpdate()
	{
		if (isServer())
		{
			if (health <= 0)
			{
				Kill();
			}
		}

		if (isMyActor())
		{
			velocity.y = Maths::Clamp(velocity.y, -1, 1);

			//set velocity to zero if low enough
			if (Maths::Abs(velocity.x) < 0.001f) velocity.x = 0;
			if (Maths::Abs(velocity.y) < 0.001f) velocity.y = 0;
			if (Maths::Abs(velocity.z) < 0.001f) velocity.z = 0;

			Collision();
			UpdateCamera();
		}
	}

	void Collision()
	{
		if (hasCollider())
		{
			// Move along x axis if no collision occurred
			Vec3f posTemp = position;
			Vec3f velTemp = velocity;
			bool collisionX = CollisionX(this, posTemp, velTemp);
			if (!collisionX)
			{
				position = posTemp;
				velocity = velTemp;
			}

			CollisionZ(this, position, velocity);

			if (collisionX)
			// Check x collision again if a collision occurred initially
			{
				CollisionX(this, position, velocity);
			}

			CollisionY(this, position, velocity);
		}
		else
		{
			position += velocity;
		}
	}

	void Render()
	{

	}

	void RenderHUD()
	{
		if (isCrosshairVisible())
		{
			DrawCrosshair(0, 8, 1, color_white);
		}

		GUI::DrawText("Position: " + interPosition.toString(), Vec2f(10, 10), color_black);
	}

	void RenderNameplate()
	{
		Vec3f pos = interPosition + Vec3f(0, 2 * scale, 0);
		if (!pos.isInFrontOfCamera()) return;
		Vec2f screenPos = pos.projectToScreen();
		GUI::DrawTextCentered(player.getCharacterName(), screenPos, color_white);
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
			(camera.getCameraType() != CameraType::FirstPerson || !isMyActor()) &&
			camera.getFrustum().containsSphere(getCenter() - camera.interPosition, cullRadius * scale)
		);
	}

	bool isNameplateVisible()
	{
		return (
			!isMyActor() &&
			getTeamNum() == getLocalPlayer().getTeamNum()
		);
	}

	bool isCrosshairVisible()
	{
		return true;
	}

	private void UpdateCamera()
	{
		camera.position = position + Vec3f(0, cameraHeight * scale, 0);
		camera.rotation = rotation;
	}

	private void DrawCrosshair(int spacing, int length, int thickness, SColor color)
	{
		Vec2f center = getDriver().getScreenCenterPos();

		Vec2f x1(length + spacing, thickness);
		Vec2f x2(spacing, -thickness);
		Vec2f y1(thickness, length + spacing);
		Vec2f y2(-thickness, spacing);

		//left/right
		GUI::DrawRectangle(center - x1, center - x2, color);
		GUI::DrawRectangle(center + x2, center + x1, color);

		//top/bottom
		GUI::DrawRectangle(center - y1, center - y2, color);
		GUI::DrawRectangle(center + y2, center + y1, color);
	}

	void OnInit()
	{
		print("Added actor: " + player.getUsername());

		if (isClient())
		{
			@camera = Camera::getCamera();
		}

		if (isMyActor())
		{
			@driver = getDriver();
			@controls = getControls();
			@mouse = Mouse::getMouse();
		}
	}

	void OnRemove()
	{
		print("Removed actor: " + player.getUsername());
	}

	void Kill()
	{
		getBlob().server_Die();
	}

	void Heal(uint health)
	{
		if (health == 0) return;

		u8 newHealth = Maths::Min(this.health + health, 255);
		SetHealth(newHealth);
	}

	void Damage(uint damage, CPlayer@ damager = null, u8 hitter = 0)
	{
		if (damage == 0) return;

		if (damager !is null)
		{
			CBlob@ blob = getBlob();
			blob.server_Hit(blob, Vec2f_zero, Vec2f_zero, 0.0f, hitter);
			blob.SetPlayerOfRecentDamage(damager, damage);
		}

		u8 newHealth = Maths::Max(int(health) - damage, 0);
		SetHealth(newHealth);
	}
}
