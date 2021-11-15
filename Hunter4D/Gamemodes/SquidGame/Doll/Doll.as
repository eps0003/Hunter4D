#include "Object.as"
#include "Actor.as"
#include "DollModel.as"
#include "Ray.as"

shared class Doll : Object
{
	uint interval = getTicksASecond() * 2;
	float moveThreshold = 0.5f;
	float rotateThreshold = 0.01f;
	float eyeHeight;

	private bool redLight = false;
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

		eyeHeight = 1.8f * scale;
	}

	void Update()
	{
		Object::Update();

		if (isServer())
		{
			bool newRedLight = getGameTime() / interval % 2 == 0;

			if (redLight != newRedLight)
			{
				SetRedLight(newRedLight);
				print(redLight ? "Red light" : "Green light");

				UpdateFreezeStates();
			}

			FreezeCheck();
		}

		if (isClient())
		{
			model.animator.SetAnimation(redLight ? "floss" : "look");
		}
	}

	void RenderHUD()
	{
		Object::RenderHUD();

		string text = redLight ? "Red light" : "Green light";
		Vec2f pos(getDriver().getScreenWidth() / 2.0f, 40);
		SColor col = redLight ? SColor(255, 255, 100, 100) : SColor(255, 100, 255, 100);
		GUI::DrawTextCentered(text, pos, col);
	}

	void Render()
	{
		model.Render();
	}

	bool getRedLight()
	{
		return redLight;
	}

	void SetRedLight(bool redLight)
	{
		if (this.redLight == redLight) return;

		this.redLight = redLight;

		if (!isClient() && hasSyncedInit)
		{
			CBitStream bs;
			bs.write_u16(id);
			bs.write_bool(redLight);
			rules.SendCommand(rules.getCommandID("set doll red light"), bs, true);
		}
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
			else
			{
				Vec3f headPos = position + Vec3f(0, eyeHeight, 0);
				Vec3f deltaPos = actor.position + Vec3f(0, actor.cameraHeight, 0) - headPos;
				Ray ray(headPos, deltaPos);

				RaycastInfo raycast;
				if (ray.raycastBlock(100, true, raycast) && raycast.distanceSq < deltaPos.magSquared()) continue;

				if (freezeState.hasMoved(moveThreshold) || freezeState.hasRotated(rotateThreshold))
				{
					actor.Kill();
					freezeStates.removeAt(i--);
				}
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
