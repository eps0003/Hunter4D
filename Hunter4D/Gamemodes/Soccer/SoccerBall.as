#include "Object.as"
#include "Actor.as"

shared class SoccerBall : Object
{
	SoccerBall(Vec3f position)
	{
		super(position);

		SetCollider(AABB(Vec3f(-0.3f), Vec3f(0.3f)));
		SetCollisionFlags(CollisionFlag::Blocks);
		SetGravity(Vec3f(0, -0.03f, 0));
		SetFriction(0.95f);
		SetElasticity(0.6f);
	}

	void Update()
	{
		Object::Update();

		if (isServer())
		{
			Actor@[]@ actors = Actor::getActors();
			for (uint i = 0; i < actors.size(); i++)
			{
				Actor@ actor = actors[i];
				if (actor.hasCollider() && getCollider().intersectsAABB(position, actor.getCollider(), actor.position))
				{
					velocity = actor.rotation.dir() * 0.5f;
				}
			}
		}
	}
}
