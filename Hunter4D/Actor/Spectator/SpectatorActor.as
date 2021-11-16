#include "Actor.as"
#include "Ray.as"

shared class SpectatorActor : Actor
{
	float acceleration = 0.2f;
	float friction = 0.4f;

	SpectatorActor(CPlayer@ player, Vec3f position, Vec3f rotation = Vec3f())
	{
		super(player, position, rotation);
	}

	SpectatorActor(Actor@ actor)
	{
		super(actor.getPlayer(), actor.position, actor.rotation);
	}

	void OnInit()
	{
		Actor::OnInit();
		SetInitCommand("init spectator actor");
	}

	void Update()
	{
		Actor::Update();

		if (isMyActor())
		{
			Vec2f dir;
			s8 verticalDir = 0;

			if (controls.ActionKeyPressed(AK_MOVE_UP)) dir.y++;
			if (controls.ActionKeyPressed(AK_MOVE_DOWN)) dir.y--;
			if (controls.ActionKeyPressed(AK_MOVE_RIGHT)) dir.x++;
			if (controls.ActionKeyPressed(AK_MOVE_LEFT)) dir.x--;
			if (controls.ActionKeyPressed(AK_ACTION3)) verticalDir++;
			if (controls.isKeyPressed(KEY_LSHIFT)) verticalDir--;

			float len = dir.Length();
			if (len > 0)
			{
				dir /= len; // Normalize
				dir = dir.RotateBy(camera.rotation.y);
			}

			// Move actor
			velocity.x += dir.x * acceleration - friction * velocity.x;
			velocity.z += dir.y * acceleration - friction * velocity.z;
			velocity.y += verticalDir * acceleration - friction * velocity.y;
		}
	}

	bool isVisible()
	{
		return false;
	}

	bool isNameplateVisible()
	{
		return false;
	}

	bool isCrosshairVisible()
	{
		return false;
	}
}
