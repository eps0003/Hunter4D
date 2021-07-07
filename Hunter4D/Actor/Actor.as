#include "Object.as"
#include "ActorCommon.as"
#include "Mouse.as"

class Actor : Object
{
	CPlayer@ player;
	float acceleration = 0.08;
	float friction = 0.3f;
	float jumpForce = 0.3f;

	Actor(CPlayer@ player, Vec3f position)
	{
		super(position);
		@this.player = player;
		SetCollisionFlags(CollisionFlag::All);
		gravity = Vec3f(0, -0.04, 0);
	}

	void opAssign(Actor actor)
	{
		opAssign(cast<Object>(actor));
	}

	void SerializeInit(CBitStream@ bs)
	{
		Object::SerializeInit(bs);
		bs.write_netid(player.getNetworkID());
	}

	void SerializeTick(CBitStream@ bs)
	{
		Object::SerializeTick(bs);
		bs.write_netid(player.getNetworkID());
	}

	bool deserializeInit(CBitStream@ bs)
	{
		if (!Object::deserializeInit(bs)) return false;

		u16 playerId;
		if (!bs.saferead_netid(playerId)) return false;

		@player = getPlayerByNetworkId(playerId);
		if (player is null) return false;

		return true;
	}

	bool deserializeTick(CBitStream@ bs)
	{
		if (!Object::deserializeTick(bs)) return false;

		u16 playerId;
		if (!bs.saferead_netid(playerId)) return false;

		@player = getPlayerByNetworkId(playerId);
		if (player is null) return false;

		return true;
	}

	void HandleSerializeInit(CPlayer@ player)
	{
		// Sync to player if server not localhost
		if (isClient()) return;

		CBitStream bs;
		SerializeInit(bs);

		if (player !is null)
		{
			getRules().SendCommand(getRules().getCommandID("init actor"), bs, player);
		}
		else
		{
			getRules().SendCommand(getRules().getCommandID("init actor"), bs, true);
		}
	}

	void HandleSerializeTick()
	{
		// Sync to server if client not localhost
		if (isServer()) return;

		// Sync my actor
		Actor@ actor = Actor::getMyActor();
		if (actor !is null)
		{
			CBitStream bs;
			SerializeTick(bs);
			getRules().SendCommand(getRules().getCommandID("sync actor"), bs, true);
		}
	}

	void HandledeserializeInit(CBitStream@ bs)
	{
		// deserialize if client not localhost
		if (isServer()) return;

		if (!deserializeInit(bs)) return;

		Actor::AddActor(this);
	}

	void HandledeserializeTick(CBitStream@ bs)
	{
		if (!deserializeTick(bs)) return;

		// Don't update my own actor
		if (player.isMyPlayer()) return;

		// Update actor
		Actor@ oldActor = Actor::getActor(player);
		if (oldActor !is null)
		{
			oldActor = this;
		}
	}

	u8 teamNum
	{
		get const
		{
			return player.getTeamNum();
		}
		set
		{
			player.server_setTeamNum(value);
		}
	}

	void Update()
	{
		Object::Update();

		if (doPhysicsUpdate())
		{
			Movement();
		}
	}

	void PostUpdate()
	{
		Object::PostUpdate();

		if (player.isMyPlayer())
		{
			UpdateCamera();
		}
	}

	bool doPhysicsUpdate()
	{
		return player.isMyPlayer();
	}

	void Collision()
	{
		if (collider is null) return;

		bool collideBlocks = hasCollisionFlags(CollisionFlag::Blocks);
		bool collideMapEdge = hasCollisionFlags(CollisionFlag::MapEdge);

		CollisionX(collideBlocks, collideMapEdge);
		CollisionZ(collideBlocks, collideMapEdge);
		if (collisionX) CollisionX(collideBlocks, collideMapEdge);
		CollisionY(collideBlocks);
	}

	void RenderHUD()
	{
		Object::RenderHUD();
		DrawCrosshair(0, 8, 1, color_white);
	}

	void RenderNameplate()
	{
		Vec3f pos = interPosition + Vec3f(0, 2, 0);
		if (!pos.isInFrontOfCamera()) return;
		Vec2f screenPos = pos.projectToScreen();
		GUI::DrawTextCentered(player.getCharacterName(), screenPos, color_white);
	}

	bool isVisible()
	{
		return !player.isMyPlayer();
	}

	bool isNameplateVisible()
	{
		return isVisible();
	}

	private void Movement()
	{
		CControls@ controls = getControls();
		Camera@ camera = Camera::getCamera();

		Vec2f dir;
		s8 verticalDir = 0;

		if (controls.isKeyPressed(KEY_KEY_W)) dir.y++;
		if (controls.isKeyPressed(KEY_KEY_S)) dir.y--;
		if (controls.isKeyPressed(KEY_KEY_D)) dir.x++;
		if (controls.isKeyPressed(KEY_KEY_A)) dir.x--;

		float len = dir.Length();
		if (len > 0)
		{
			dir /= len; // Normalize
			dir = dir.RotateBy(camera.rotation.y);
		}

		if (controls.isKeyPressed(KEY_SPACE) && collider.intersectsNewSolid(position, position + Vec3f(0, -0.001f, 0)))
		{
			velocity.y = jumpForce;
		}

		// Move actor
		velocity.x += dir.x * acceleration - friction * velocity.x;
		velocity.z += dir.y * acceleration - friction * velocity.z;
	}

	private void UpdateCamera()
	{
		Camera@ camera = Camera::getCamera();
		Mouse@ mouse = Mouse::getMouse();

		// Move and rotate camera
		camera.position = position;
		camera.rotation = camera.rotation + Vec3f(mouse.velocity.y, mouse.velocity.x, 0);
		camera.rotation = Vec3f(
			Maths::Clamp(camera.rotation.x, -90, 90),
			camera.rotation.y,
			Maths::Clamp(camera.rotation.z, -90, 90)
		);
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
	}

	void OnRemove()
	{
		print("Removed actor: " + player.getUsername());
		player.set("actor", null);
	}
}
