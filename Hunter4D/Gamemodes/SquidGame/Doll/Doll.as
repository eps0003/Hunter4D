#include "Object.as"
#include "Actor.as"
#include "DollModel.as"

shared class Doll : Object
{
	float jumpInterval = 1.0f;
	float jumpForce = 0.3f;
	float forwardForce = 0.2f;
	private bool midJump = false;

	DollModel@ model;

	Doll(Vec3f position)
	{
		super("Doll", position);

		SetCollider(AABB(Vec3f(-0.3f, 0.0f, -0.3f), Vec3f(0.3f, 1.8f, 0.3f)));
		SetCollisionFlags(CollisionFlag::All);
		SetGravity(Vec3f(0, -0.04f, 0));
		SetFriction(0.5f);
	}

	void OnInit()
	{
		Object::OnInit();
		SetInitCommand("init doll");

		if (isClient())
		{
			SetCullRadius(6.0f);
			@model = DollModel(this);
		}
	}

	void Render()
	{
		model.Render();
	}
}
