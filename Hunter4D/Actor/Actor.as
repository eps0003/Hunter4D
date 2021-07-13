#include "ActorCommon.as"
#include "Mouse.as"
#include "Collision.as"

class Actor : ICollision
{
	private u16 id = 0;
	private CPlayer@ player;

	bool hasSyncedInit = false;

	private Vec3f gravity;
	float acceleration = 0.08;
	float friction = 0.3f;
	float jumpForce = 0.3f;

	Vec3f position;
	private Vec3f oldPosition;
	Vec3f interPosition;

	Vec3f velocity;

	private AABB@ collider;
	private u8 collisionFlags = 0;

	private uint lastUpdate = 0;

	private float[] matrix;

	private CRules@ rules = getRules();

	Actor()
	{
		Matrix::MakeIdentity(matrix);
	}

	Actor(CPlayer@ player, Vec3f position)
	{
		@this.player = player;
		this.position = position;
		oldPosition = position;
		id = rules.add_u32("id", 1);

		SetCollider(AABB(Vec3f(-0.3f, -1.6f, -0.3f), Vec3f(0.3f, 0.1f, 0.3f)));
		SetCollisionFlags(CollisionFlag::All);
		SetGravity(Vec3f(0, -0.04f, 0));
	}

	void opAssign(Actor actor)
	{
		oldPosition = position;

		position = actor.position;
		velocity = actor.velocity;

		lastUpdate = getGameTime();
	}

	u16 getID()
	{
		return id;
	}

	CPlayer@ getPlayer()
	{
		return player;
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
			rules.SendCommand(rules.getCommandID("set actor collision flags"), bs, true);
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
			rules.SendCommand(rules.getCommandID("set actor gravity"), bs, true);
		}
	}

	void SerializeInit(CPlayer@ player = null, CBitStream@ bs = CBitStream(), string commandName = "init actor")
	{
		bs.write_netid(this.player.getNetworkID());
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

	void SerializeTick(CBitStream@ bs = CBitStream(), string commandName = "sync actor")
	{
		bs.write_u16(id);
		position.Serialize(bs);
		velocity.Serialize(bs);

		rules.SendCommand(rules.getCommandID(commandName), bs, true);
	}

	void SerializeRemove(CBitStream@ bs = CBitStream(), string commandName = "remove actor")
	{
		bs.write_u16(id);

		rules.SendCommand(rules.getCommandID(commandName), bs, true);
	}

	void DeserializeInit(CBitStream@ bs)
	{
		u16 playerId;
		if (!bs.saferead_netid(playerId)) return;

		@player = getPlayerByNetworkId(playerId);
		if (player is null) return;

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

		Actor::AddActor(this);
	}

	void DeserializeTick(CBitStream@ bs)
	{
		if (!bs.saferead_u16(id)) return;
		if (!position.deserialize(bs)) return;
		if (!velocity.deserialize(bs)) return;

		// Update actor
		Actor@ oldActor = Actor::getActor(id);
		if (oldActor !is null && !oldActor.getPlayer().isMyPlayer())
		{
			oldActor = this;
		}
	}

	void DeserializeRemove(CBitStream@ bs)
	{
		if (!bs.saferead_u16(id)) return;

		Actor::RemoveActor(id);
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
		if (player.isMyPlayer() || getGameTime() > lastUpdate + 1)
		{
			oldPosition = position;
		}
	}

	void Update()
	{
		if (player.isMyPlayer())
		{
			Movement();
		}
	}

	void PostUpdate()
	{
		if (player.isMyPlayer())
		{
			velocity.y = Maths::Clamp(velocity.y, -1, 1);

			//set velocity to zero if low enough
			if (Maths::Abs(velocity.x) < 0.001f) velocity.x = 0;
			if (Maths::Abs(velocity.y) < 0.001f) velocity.y = 0;
			if (Maths::Abs(velocity.z) < 0.001f) velocity.z = 0;

			Collision();
			UpdateCamera();
		}

		if (isServer())
		{
			if (position.y <= -10)
			{
				Kill();
			}
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

			// Check x collision again if a collision occurred initially
			if (collisionX)
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
		Matrix::SetTranslation(matrix, interPosition.x, interPosition.y, interPosition.z);
		Render::SetModelTransform(matrix);

		Vec3f min = collider.min;
		Vec3f max = collider.max;

		CTeam@ team = rules.getTeam(getTeamNum());
		SColor color = team !is null ? team.color : color_white;

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
		DrawCrosshair(0, 8, 1, color_white);
		GUI::DrawText("Position: " + interPosition.toString(), Vec2f(10, 10), color_black);
	}

	void RenderNameplate()
	{
		Vec3f pos = interPosition + Vec3f(0, 2, 0);
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
	}

	bool isVisible()
	{
		return !player.isMyPlayer() && hasCollider();
	}

	bool isNameplateVisible()
	{
		u8 localTeam = getLocalPlayer().getTeamNum();
		return (
			isVisible() &&
			(getTeamNum() == localTeam || localTeam == rules.getSpectatorTeamNum())
		);
	}

	bool isOnGround()
	{
		return hasCollider() && collider.intersectsNewSolid(position, position + Vec3f(0, -0.001f, 0));
	}

	private void Movement()
	{
		CControls@ controls = getControls();
		Camera@ camera = Camera::getCamera();

		Vec2f dir;
		s8 verticalDir = 0;

		if (controls.ActionKeyPressed(AK_MOVE_UP)) dir.y++;
		if (controls.ActionKeyPressed(AK_MOVE_DOWN)) dir.y--;
		if (controls.ActionKeyPressed(AK_MOVE_RIGHT)) dir.x++;
		if (controls.ActionKeyPressed(AK_MOVE_LEFT)) dir.x--;

		float len = dir.Length();
		if (len > 0)
		{
			dir /= len; // Normalize
			dir = dir.RotateBy(camera.rotation.y);
		}

		velocity += gravity;

		if (controls.ActionKeyPressed(AK_ACTION3) && isOnGround())
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
	}

	void Kill()
	{
		player.getBlob().server_Die();
	}
}
