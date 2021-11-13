#include "Object.as"
#include "Actor.as"
#include "DollModel.as"

shared class Doll : Object
{
	uint interval = getTicksASecond() * 5;
	bool redLight = false;
	float moveThreshold = 0.5f;
	float rotateThreshold = 0.01f;

	DollModel@ model;

	private FreezeState[] freezeStates;

	Doll(Vec3f position)
	{
		super("Doll", position, Vec3f(), 2.0f);

		SetCollider(AABB(Vec3f(-0.3f, 0.0f, -0.3f) * scale, Vec3f(0.3f, 1.8f, 0.3f) * scale));
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
			SetCullRadius(scale);
			@model = DollModel(this, scale);
		}
	}

	void Update()
	{
		Object::Update();

		if (isServer())
		{
			bool newRedLight = getGameTime() / interval % 2 == 0;

			if (redLight != newRedLight)
			{
				redLight = newRedLight;
				print(redLight ? "Red light" : "Green light");

				UpdateFreezeStates();
			}

			FreezeCheck();
		}
	}

	void Render()
	{
		model.Render();
	}

	private void UpdateFreezeStates()
	{
		freezeStates.clear();

		if (redLight)
		{
			Actor@[] actors = Actor::getActors();
			for (uint i = 0; i < actors.size(); i++)
			{
				Actor@ actor = actors[i];
				if (actor.getTeamNum() != rules.getSpectatorTeamNum())
				{
					freezeStates.push_back(FreezeState(actor));
				}
			}
		}
	}

	private void FreezeCheck()
	{
		for (uint i = 0; i < freezeStates.size(); i++)
		{
			FreezeState freezeState = freezeStates[i];

			Actor@ actor = freezeState.actor;
			if (actor is null)
			{
				freezeStates.removeAt(i--);
			}
			else if (freezeState.hasMoved(moveThreshold) || freezeState.hasRotated(rotateThreshold))
			{
				actor.Kill();
				freezeStates.removeAt(i--);
			}
		}
	}
}

shared class FreezeState
{
	Actor@ actor;
	Vec3f position;
	Vec3f lookDir;

	FreezeState(Actor@ actor)
	{
		@this.actor = actor;
		position = actor.position;
		lookDir = actor.rotation.dir();
	}

	bool hasMoved(float threshold)
	{
		float lenSq = (actor.position - position).magSquared();
		return lenSq > threshold * threshold;
	}

	bool hasRotated(float threshold)
	{
		float lookDot = actor.rotation.dir().dot(lookDir);
		return lookDot < 1 - threshold;
	}
}