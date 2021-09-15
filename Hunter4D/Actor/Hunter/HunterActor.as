#include "Actor.as"
#include "Gun.as"

shared class HunterActor : Actor
{
	float acceleration = 0.08f;
	float friction = 0.3f;
	float jumpForce = 0.3f;

	ActorModel@ model;
	private Gun@ gun;

	HunterActor(CPlayer@ player, Vec3f position)
	{
		super(player, position);

		SetCollider(AABB(Vec3f(-0.3f, 0.0f, -0.3f), Vec3f(0.3f, 1.8f, 0.3f)));
		SetCollisionFlags(CollisionFlag::All);
		SetGravity(Vec3f(0, -0.04f, 0));
	}

	void OnInit()
	{
		Actor::OnInit();
		SetInitCommand("init hunter actor");

		@gun = Gun(this);

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

		if (isClient())
		{
			if (isOnGround())
			{
				if (velocity.toXZ().LengthSquared() > 0.005f)
				{
					model.SetAnimation("run");
				}
				else
				{
					model.SetAnimation("idle");
				}
			}
			else
			{
				model.SetAnimation("jump");
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
		gun.Render();
	}

	private void Movement()
	{
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

		if (isOnGround() && controls.ActionKeyPressed(AK_ACTION3))
		{
			velocity.y = jumpForce;
		}

		// Move actor
		velocity.x += dir.x * acceleration - friction * velocity.x;
		velocity.z += dir.y * acceleration - friction * velocity.z;
	}
}
