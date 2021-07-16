#include "Object.as"
#include "Actor.as"

shared class Blob : Object
{
	float jumpInterval = 1.0f;
	float jumpForce = 0.3f;
	float forwardForce = 0.2f;
	private uint spawnTime;
	private bool midJump = false;

	Blob(Vec3f position)
	{
		super(position);

		SetCollider(AABB(Vec3f(-0.3f), Vec3f(0.3f)));
		SetCollisionFlags(CollisionFlag::All);
		SetGravity(Vec3f(0, -0.04f, 0));
		SetFriction(0.5f);

		spawnTime = getGameTime();
	}

	void Update()
	{
		Object::Update();

		if (isServer())
		{
			Actor@[]@ actors = Actor::getActors();
			if (actors.size() > 0)
			{
				Actor@ actor = actors[0];

				if ((getGameTime() - spawnTime) % Maths::Round(getTicksASecond() * jumpInterval) == 0)
				{
					Vec3f dir = actor.position - position;
					dir.y = 0;
					dir.SetMag(forwardForce);
					dir.y = jumpForce;

					velocity.y = jumpForce;
					midJump = true;
				}

				if (midJump)
				{
					Vec3f dir = actor.position - position;
					dir.y = 0;
					dir.SetMag(forwardForce);

					velocity.x = dir.x;
					velocity.z = dir.z;
				}
			}
		}
	}

	void PostUpdate()
	{
		Object::PostUpdate();

		if (isServer())
		{
			if (isOnGround())
			{
				midJump = false;
			}
		}
	}
}
