#include "Object.as"
#include "Actor.as"

shared class Doll : Object
{
	float jumpInterval = 1.0f;
	float jumpForce = 0.3f;
	float forwardForce = 0.2f;
	private bool midJump = false;

	ActorModel@ model;

	Doll(Vec3f position)
	{
		super(position);

		SetCollider(AABB(Vec3f(-0.3f, 0.0f, -0.3f), Vec3f(0.3f, 1.8f, 0.3f)));
		SetCollisionFlags(CollisionFlag::All);
		SetGravity(Vec3f(0, -0.04f, 0));
		SetFriction(0.5f);
	}

	void OnInit()
	{
		Actor::OnInit();
		SetInitCommand("init doll object");

		if (isClient())
		{
			@model = ActorModel(this);
		}
	}

	void Update()
	{
		Object::Update();
	}
}
