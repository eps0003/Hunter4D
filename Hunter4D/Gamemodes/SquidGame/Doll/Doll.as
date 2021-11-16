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
		super("Doll", position, Vec3f(), 4.0f);

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

		if (isServer() && rules.isMatchRunning())
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
			Actor@[]@ actors = Actor::getActors();
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
		Actor@[]@ actors = Actor::getActors();

		for (int i = freezeStates.size() - 1; i >= 0; i--)
		{
			FreezeState freezeState = freezeStates[i];

			Actor@ actor = freezeState.actor;
			if (actor is null)
			{
				freezeStates.removeAt(i);
			}
			else
			{
				// Create ray from doll to player
				Vec3f dollHeadPos = position + Vec3f(0, eyeHeight, 0);
				Vec3f actorHeadPos = actor.position + Vec3f(0, actor.cameraHeight, 0);
				Vec3f deltaPos = actorHeadPos - dollHeadPos;
				Ray ray(dollHeadPos, deltaPos);

				// Check if block is obstructing view
				RaycastInfo raycast;
				if (ray.raycastBlock(200, true, raycast) && raycast.distanceSq < deltaPos.magSquared()) continue;

				// Check if another player is obstructing view
				bool objectBlocking = false;

				for (uint i = 0; i < actors.size(); i++)
				{
					Actor@ otherActor = actors[i];
					if (otherActor is actor) continue;

					// Calculate model matrix for hurtbox
					float[] modelMatrix;
					Matrix::MakeIdentity(modelMatrix);
					Matrix::SetTranslation(modelMatrix, otherActor.position.x, otherActor.position.y, otherActor.position.z);
					Matrix::SetRotationDegrees(modelMatrix, 0, -otherActor.rotation.y, 0);

					// Perform raycast
					float distance;
					if (ray.intersectsOBB(otherActor.getCollider(), modelMatrix, distance) && distance * distance < deltaPos.magSquared())
					{
						objectBlocking = true;
						break;
					}
				}

				if (objectBlocking) continue;

				// Kill player if they have moved or rotated
				if (freezeState.hasMoved(moveThreshold) || freezeState.hasRotated(rotateThreshold))
				{
					actor.Kill();
					freezeStates.removeAt(i);
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
