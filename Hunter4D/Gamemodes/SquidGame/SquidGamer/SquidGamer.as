#include "Actor.as"

shared class SquidGamer : Actor
{
	float acceleration = 0.08f;
	float friction = 0.3f;
	float jumpForce = 0.3f;
	float pushRange = 2.0f;
	float pushForce = 2.0f;

	ActorModel@ model;

	SquidGamer(CPlayer@ player, Vec3f position)
	{
		super(player, position);

		SetCollider(AABB(Vec3f(-0.3f, 0.0f, -0.3f), Vec3f(0.3f, 1.8f, 0.3f)));
		SetCollisionFlags(CollisionFlag::All);
		SetGravity(Vec3f(0, -0.04f, 0));
	}

	void OnInit()
	{
		Actor::OnInit();
		SetInitCommand("init squid gamer");

		if (isClient())
		{
			@model = ActorModel(this);
		}
	}

	void Update()
	{
		Actor::Update();

		if (isMyActor())
		{
			Movement();
		}

		if (isServer() && !rules.isWarmup())
		{
			PushPlayers();
		}

		if (isClient())
		{
			if (isOnGround())
			{
				if (velocity.toXZ().LengthSquared() > 0.005f)
				{
					model.animator.SetAnimation("run");
				}
				else
				{
					model.animator.SetAnimation("idle");
				}
			}
			else
			{
				model.animator.SetAnimation("jump");
			}
		}
	}

	void PostUpdate()
	{
		Actor::PostUpdate();

		if (isServer())
		{
			if (position.y <= -10)
			{
				Kill();
			}
		}
	}

	void Render()
	{
		Actor::Render();
		model.Render();
	}

	private void Movement()
	{
		Vec2f dir;
		s8 verticalDir = 0;

		if (!rules.isWarmup())
		{
			if (controls.ActionKeyPressed(AK_MOVE_UP)) dir.y++;
			if (controls.ActionKeyPressed(AK_MOVE_DOWN)) dir.y--;
			if (controls.ActionKeyPressed(AK_MOVE_RIGHT)) dir.x++;
			if (controls.ActionKeyPressed(AK_MOVE_LEFT)) dir.x--;

			if (isOnGround() && controls.ActionKeyPressed(AK_ACTION3))
			{
				velocity.y = jumpForce;
			}

			float len = dir.Length();
			if (len > 0)
			{
				dir /= len; // Normalize
				dir = dir.RotateBy(camera.rotation.y);
			}
		}

		// Move actor
		velocity.x += dir.x * acceleration - friction * velocity.x;
		velocity.z += dir.y * acceleration - friction * velocity.z;
	}

	private void PushPlayers()
	{
		// Press either left or right mouse button to shoot
		bool left = getBlob().isKeyJustPressed(key_action1);
		bool right = getBlob().isKeyJustPressed(key_action2);
		if (!left && !right) return;

		// Create ray
		Ray ray(position + Vec3f(0, cameraHeight, 0), rotation.dir());

		Actor@ closestActor;
		float closestDistance = pushRange;

		// Find closest actor
		Actor@[]@ actors = Actor::getActors();
		for (uint i = 0; i < actors.size(); i++)
		{
			Actor@ actor = actors[i];
			if (actor is this) continue;

			// Calculate model matrix for hurtbox
			float[] modelMatrix;
			Matrix::MakeIdentity(modelMatrix);
			Matrix::SetTranslation(modelMatrix, actor.position.x, actor.position.y, actor.position.z);
			Matrix::SetRotationDegrees(modelMatrix, 0, -actor.rotation.y, 0);

			// Perform raycast
			float distance;
			if (ray.intersectsOBB(actor.getCollider(), modelMatrix, distance))
			{
				if (distance <= closestDistance)
				{
					@closestActor = actor;
					closestDistance = distance;
				}
			}
		}

		// Push closest actor
		if (closestActor !is null)
		{
			closestActor.SetVelocity(ray.direction * pushForce);

			print(getPlayer().getUsername() + " pushed " + closestActor.getPlayer().getUsername());

			CBitStream bs;
			bs.write_netid(getPlayer().getNetworkID());
			bs.write_netid(closestActor.getPlayer().getNetworkID());
			rules.SendCommand(rules.getCommandID("squid gamer pushed"), bs, true);
		}
	}
}
