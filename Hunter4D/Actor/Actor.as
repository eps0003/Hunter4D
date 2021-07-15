#include "ActorCommon.as"
#include "Mouse.as"
#include "Collision.as"
#include "ModelSegment.as"

class Actor : ICollision
{
	private u16 id = 0;
	private CPlayer@ player;

	private string initCommand = "init actor";
	private string syncCommand = "sync actor";
	private string removeCommand = "remove actor";

	bool hasSyncedInit = false;

	private Vec3f gravity;

	Vec3f position;
	private Vec3f oldPosition;
	Vec3f interPosition;

	Vec3f velocity;
	private Vec3f oldVelocity;
	Vec3f interVelocity;

	private AABB@ collider;
	private u8 collisionFlags = 0;

	private uint lastUpdate = 0;

	private float cameraHeight = 1.6f;

	private ModelSegment@ head;
	private ModelSegment@ body;
	private ModelSegment@ upperLeftArm;
	private ModelSegment@ lowerLeftArm;
	private ModelSegment@ upperRightArm;
	private ModelSegment@ lowerRightArm;
	private ModelSegment@ upperLeftLeg;
	private ModelSegment@ lowerLeftLeg;
	private ModelSegment@ upperRightLeg;
	private ModelSegment@ lowerRightLeg;

	private float[] matrix;

	private CRules@ rules = getRules();
	private Camera@ camera;
	private Mouse@ mouse;

	Actor(CPlayer@ player, Vec3f position)
	{
		@this.player = player;
		this.position = position;
		oldPosition = position;
		id = rules.add_u32("id", 1);
	}

	void opAssign(Actor actor)
	{
		oldPosition = position;
		oldVelocity = velocity;

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

	void SerializeInit(CPlayer@ player = null, CBitStream@ bs = CBitStream())
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
			oldVelocity = velocity;
		}
	}

	void Update()
	{
		if (player.isMyPlayer())
		{
			velocity += gravity;
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
		float gt = Interpolation::getGameTime() * 0.4f;
		float vel = interVelocity.toXZ().Length() * 4.0f;

		float sin = Maths::Sin(gt) * vel;
		float cos = Maths::Cos(gt) * vel;

		float limbSin = sin * 40.0f;
		float limbCos = cos * 40.0f;

		head.position = Vec3f(0, 0.75f, 0);
		head.rotation = Vec3f(camera.interRotation.x, 0, 0);

		body.position = Vec3f(0, 0.75f + Maths::Abs(cos * 0.1f), 0);
		body.rotation = Vec3f(Maths::Sin(gt * 2.0f) * vel * -4.0f, 0, 0);

		// Left arm

		upperLeftArm.position = Vec3f(-0.25f, 0.75f, 0);
		upperLeftArm.rotation = Vec3f(-limbCos, 0, 0);

		lowerLeftArm.position = Vec3f(-0.125f, -0.375f, -0.125f);
		lowerLeftArm.rotation = Vec3f(Maths::Max(0, -limbCos), 0, 0);

		// Right arm

		upperRightArm.position = Vec3f(0.25f, 0.75f, 0);
		upperRightArm.rotation = Vec3f(limbCos, 0, 0);

		lowerRightArm.position = Vec3f(0.125f, -0.375f, -0.125f);
		lowerRightArm.rotation = Vec3f(Maths::Max(0, limbCos), 0, 0);

		// Left leg

		upperLeftLeg.rotation = Vec3f(limbCos, 0, 0);

		lowerLeftLeg.position = Vec3f(-0.125f, -0.375f, 0.125f);
		lowerLeftLeg.rotation = Vec3f(Maths::Min(0, limbSin), 0, 0);

		// Right leg

		upperRightLeg.rotation = Vec3f(-limbCos, 0, 0);

		lowerRightLeg.position = Vec3f(0.125f, -0.375f, 0.125f);
		lowerRightLeg.rotation = Vec3f(Maths::Min(0, -limbSin), 0, 0);

		// Render

		Matrix::SetTranslation(matrix, interPosition.x, interPosition.y, interPosition.z);
		Matrix::SetRotationDegrees(matrix, 0, -camera.interRotation.y, 0);

		float[] scaleMatrix;
		Matrix::MakeIdentity(scaleMatrix);
		Matrix::SetScale(scaleMatrix, 0.9f, 0.9f, 0.9f);
		Matrix::MultiplyImmediate(matrix, scaleMatrix);

		Render::SetBackfaceCull(false);
		Render::SetAlphaBlend(true);
		body.Render(matrix);
		Render::SetAlphaBlend(false);
		Render::SetBackfaceCull(true);
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
		interVelocity = oldVelocity.lerp(velocity, t);
	}

	bool isVisible()
	{
		return true; //!player.isMyPlayer() && hasCollider();
	}

	bool isNameplateVisible()
	{
		return false;
		u8 localTeam = getLocalPlayer().getTeamNum();
		return (
			isVisible() &&
			(getTeamNum() == localTeam || localTeam == rules.getSpectatorTeamNum())
		);
	}

	bool isCrosshairVisible()
	{
		return true;
	}

	bool isOnGround()
	{
		return hasCollider() && collider.intersectsNewSolid(position, position + Vec3f(0, -0.001f, 0));
	}

	private void UpdateCamera()
	{
		// Move and rotate camera
		camera.position = position + Vec3f(0, cameraHeight, 0);
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

		if (isClient())
		{
			Matrix::MakeIdentity(matrix);

			@head = ModelSegment("ActorHead.obj");
			@body = ModelSegment("ActorBody.obj");
			@upperLeftArm = ModelSegment("ActorUpperLeftArm.obj");
			@lowerLeftArm = ModelSegment("ActorLowerLeftArm.obj");
			@upperRightArm = ModelSegment("ActorUpperRightArm.obj");
			@lowerRightArm= ModelSegment("ActorLowerRightArm.obj");
			@upperLeftLeg = ModelSegment("ActorUpperLeftLeg.obj");
			@lowerLeftLeg = ModelSegment("ActorLowerLeftLeg.obj");
			@upperRightLeg = ModelSegment("ActorUpperRightLeg.obj");
			@lowerRightLeg = ModelSegment("ActorLowerRightLeg.obj");

			SMaterial@ material = head.mesh.GetMaterial();
			material.AddTexture("KnightSkin.png");
			material.SetFlag(SMaterial::LIGHTING, false);
			material.SetFlag(SMaterial::BILINEAR_FILTER, false);

			head.mesh.SetMaterial(material);
			body.mesh.SetMaterial(material);
			upperLeftArm.mesh.SetMaterial(material);
			lowerLeftArm.mesh.SetMaterial(material);
			upperRightArm.mesh.SetMaterial(material);
			lowerRightArm.mesh.SetMaterial(material);
			upperLeftLeg.mesh.SetMaterial(material);
			lowerLeftLeg.mesh.SetMaterial(material);
			upperRightLeg.mesh.SetMaterial(material);
			lowerRightLeg.mesh.SetMaterial(material);

			body.AddChild(head);
			body.AddChild(upperLeftArm);
			body.AddChild(upperRightArm);
			body.AddChild(upperLeftLeg);
			body.AddChild(upperRightLeg);

			upperLeftArm.AddChild(lowerLeftArm);
			upperRightArm.AddChild(lowerRightArm);
			upperLeftLeg.AddChild(lowerLeftLeg);
			upperRightLeg.AddChild(lowerRightLeg);
		}

		if (player.isMyPlayer())
		{
			@camera = Camera::getCamera();
			@mouse = Mouse::getMouse();
		}
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
