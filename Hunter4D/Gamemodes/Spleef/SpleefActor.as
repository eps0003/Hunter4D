#include "Actor.as"
#include "Ray.as"

shared class SpleefActor : Actor
{
	float acceleration = 0.08f;
	float friction = 0.3f;
	float jumpForce = 0.3f;

	SpleefActor(CPlayer@ player, Vec3f position)
	{
		super(player, position);

		SetCollider(AABB(Vec3f(-0.3f, 0.0f, -0.3f), Vec3f(0.3f, 1.8f, 0.3f)));
		SetCollisionFlags(CollisionFlag::All);
		SetGravity(Vec3f(0, -0.04f, 0));
	}

	void OnInit()
	{
		Actor::OnInit();

		SetInitCommand("init spleef actor");
	}

	void Update()
	{
		Actor::Update();

		if (isMyActor())
		{
			Movement();

			if (canDestroyBlocks())
			{
				bool left = controls.ActionKeyPressed(AK_ACTION1);
				bool right = controls.ActionKeyPressed(AK_ACTION2);

				if (left || right)
				{
					Ray ray(camera.position, camera.rotation.dir());

					RaycastInfo raycast;
					if (ray.raycastBlock(6, false, raycast))
					{
						Vec3f position = raycast.hitWorldPos;
						map.ClientSetBlockSafe(position, 0);
					}
				}
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

	bool canDestroyBlocks()
	{
		return mouse.isInControl() && rules.getCurrentState() != WARMUP;
	}
}
