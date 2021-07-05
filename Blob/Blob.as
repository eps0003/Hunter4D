#include "Object.as"

class Blob : Object
{
    float jumpInterval = 1.0f;
	float jumpForce = 0.4f;

	Blob(Vec3f position)
	{
		super(position);
		SetCollisionFlags(CollisionFlag::All);
		SetGravity(Vec3f(0, -0.04f, 0));
	}

	void Update()
	{
		Object::Update();

		if (doPhysicsUpdate())
		{
			if (getGameTime() % Maths::Round(getTicksASecond() * jumpInterval) == 0)
            {
                velocity.y = jumpForce;
            }
		}
	}
}
