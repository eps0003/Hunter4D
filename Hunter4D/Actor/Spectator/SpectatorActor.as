#include "Actor.as"
#include "Ray.as"

class SpectatorActor : Actor
{
	float acceleration = 0.2f;
	float friction = 0.4f;

	SpectatorActor(CPlayer@ player, Vec3f position)
	{
		super(player, position);
	}

	void OnInit()
	{
		Actor::OnInit();
		SetInitCommand("init spectator actor");
	}

	void Update()
	{
		if (player.isMyPlayer())
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

	bool isCrosshairVisible()
	{
		return false;
	}
}
