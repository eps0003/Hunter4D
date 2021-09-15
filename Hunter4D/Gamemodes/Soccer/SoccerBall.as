#include "Object.as"
#include "Actor.as"
#include "SoccerBallModel.as"

shared class SoccerBall : Object
{
	Model@ model;
	float radius = 0.25f;

	SoccerBall(Vec3f position)
	{
		super(position);

		SetCollider(AABB(Vec3f(-radius), Vec3f(radius)));
		SetCollisionFlags(CollisionFlag::Blocks);
		SetGravity(Vec3f(0, -0.03f, 0));
		SetFriction(0.95f);
		SetElasticity(0.6f);
	}

	void OnInit()
	{
		Object::OnInit();

		SetInitCommand("init soccer ball object");

		if (isClient())
		{
			@model = SoccerBallModel(this);
		}
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

			FakeRolling();
		}
	}

	void PostUpdate()
	{
		Object::PostUpdate();

		if (isServer())
		{
			if (position.y <= -10)
			{
				Object::RemoveObject(this);
			}
		}
	}

	void Render()
	{
		model.Render();
	}

	private void FakeRolling()
	{
		Vec2f vel = velocity.toXZ();
		if (vel.LengthSquared() > 0)
		{
			rotation.y = -vel.AngleDegrees() - 90;
			rotation.x -= Maths::toDegrees(vel.Length() / radius);
		}
	}
}
