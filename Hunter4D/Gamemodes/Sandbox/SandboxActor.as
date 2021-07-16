#include "Actor.as"
#include "Ray.as"

shared class SandboxActor : Actor
{
	private Map@ map;
	private Driver@ driver;

	float acceleration = 0.08f;
	float friction = 0.3f;
	float jumpForce = 0.3f;

	u8 selectedIndex = 0;
	SColor[] colors = {
		SColor(255, 229, 59, 68),	// Red
		SColor(255, 255, 173, 52),	// Orange
		SColor(255, 255, 231, 98),	// Yellow
		SColor(255, 99, 198, 77),	// Lime
		SColor(255, 38, 92, 66),	// Dark green
		SColor(255, 0, 149, 233),	// Light blue
		SColor(255, 18, 79, 136),	// Dark blue
		SColor(255, 104, 55, 108),	// Purple
		SColor(255, 24, 20, 37)		// Dark purple
	};

	private ActorModel@ model;
	private ActorIdleAnim@ idleAnim;
	private ActorRunAnim@ runAnim;
	private ActorJumpAnim@ jumpAnim;
	private ActorJumpingJacksAnim@ jumpingJacksAnim;

	bool taunting = false;

	SandboxActor(CPlayer@ player, Vec3f position)
	{
		super(player, position);

		SetCollider(AABB(Vec3f(-0.3f, 0.0f, -0.3f), Vec3f(0.3f, 1.8f, 0.3f)));
		SetCollisionFlags(CollisionFlag::All);
		SetGravity(Vec3f(0, -0.04f, 0));
	}

	void OnInit()
	{
		Actor::OnInit();

		SetInitCommand("init sandbox actor");
		SetSyncCommand("sync sandbox actor");

		if (isMyActor())
		{
			@map = Map::getMap();
			@driver = getDriver();
		}

		if (isClient())
		{
			@model = ActorModel(this, "KnightSkin.png");
			@idleAnim = ActorIdleAnim(model);
			@runAnim = ActorRunAnim(model);
			@jumpAnim = ActorJumpAnim(model);
			@jumpingJacksAnim = ActorJumpingJacksAnim(model);
		}
	}

	void opAssign(SandboxActor actor)
	{
		opAssign(cast<Actor>(actor));
		taunting = actor.taunting;
	}

	void Update()
	{
		Actor::Update();

		if (isMyActor())
		{
			taunting = controls.ActionKeyPressed(AK_TAUNTS);

			Movement();
			ChangeBlockColor();
			BlockPlacement();
		}

		if (isClient())
		{
			if (taunting)
			{
				model.SetAnimation(jumpingJacksAnim);
			}
			else
			{
				if (isOnGround())
				{
					if (velocity.magSquared() > 0.005f)
					{
						model.SetAnimation(runAnim);
					}
					else
					{
						model.SetAnimation(idleAnim);
					}
				}
				else
				{
					model.SetAnimation(jumpAnim);
				}
			}
		}
	}

	void RenderHUD()
	{
		Actor::RenderHUD();

		int n = colors.size();
		Vec2f center = driver.getScreenCenterPos();
		int spacing = 10;
		int selectedBorder = 4;
		int size = 50;
		int numOffset = 12;
		int y = 20;

		for (int i = 0; i < n; i++)
		{
			SColor color = colors[i];

			float offset = i - (n / 2.0f);
			int x = center.x + offset * size + offset * spacing;

			if (i == selectedIndex)
			{
				GUI::DrawRectangle(
					Vec2f(x - selectedBorder, y - selectedBorder),
					Vec2f(x + size + selectedBorder, y + size + selectedBorder),
					color_white
				);
			}

			GUI::DrawRectangle(Vec2f(x, y), Vec2f(x + size, y + size), color);
			GUI::DrawTextCentered(
				"" + (i + 1),
				Vec2f(x + size - numOffset, y + size - numOffset),
				color_white
			);
		}
	}

	void Render()
	{
		Actor::Render();
		model.Render();
	}

	private void Movement()
	{
		Vec2f dir;
		s8 verticalDir = 0;

		if (!taunting)
		{
			if (controls.ActionKeyPressed(AK_MOVE_UP)) dir.y++;
			if (controls.ActionKeyPressed(AK_MOVE_DOWN)) dir.y--;
			if (controls.ActionKeyPressed(AK_MOVE_RIGHT)) dir.x++;
			if (controls.ActionKeyPressed(AK_MOVE_LEFT)) dir.x--;

			float len = dir.Length();
			if (len > 0)
			{
				dir /= len; // Normalize
				dir = dir.RotateBy(camera.rotation.y);
			}

			if (isOnGround() && controls.ActionKeyPressed(AK_ACTION3))
			{
				velocity.y = jumpForce;
			}
		}

		// Move actor
		velocity.x += dir.x * acceleration - friction * velocity.x;
		velocity.z += dir.y * acceleration - friction * velocity.z;
	}

	private void ChangeBlockColor()
	{
		for (uint i = 0; i < 9; i++)
		{
			if (controls.isKeyJustPressed(KEY_KEY_1 + i))
			{
				selectedIndex = i;
				break;
			}
		}

		s8 scrollDir = 0;
		if (controls.mouseScrollUp) scrollDir--;
		if (controls.mouseScrollDown) scrollDir++;
		selectedIndex = (selectedIndex + scrollDir + colors.size()) % colors.size();
	}

	private void BlockPlacement()
	{
		if (!mouse.isInControl()) return;

		bool left = controls.isKeyJustPressed(controls.getActionKeyKey(AK_ACTION1));
		bool right = controls.isKeyJustPressed(controls.getActionKeyKey(AK_ACTION2));
		if (!left && !right) return;

		Ray ray(camera.position, camera.rotation.dir());
		RaycastInfo raycast;
		if (!ray.raycastBlock(6, false, raycast)) return;

		if (left)
		{
			Vec3f position = raycast.hitWorldPos + raycast.normal;
			map.ClientSetBlockSafe(position, colors[selectedIndex]);
		}
		else
		{
			Vec3f position = raycast.hitWorldPos;
			map.ClientSetBlockSafe(position, 0);
		}
	}

	void SerializeTick(CBitStream@ bs = CBitStream())
	{
		bs.write_bool(taunting);
		Actor::SerializeTick(bs);
	}

	void DeserializeTick(CBitStream@ bs)
	{
		if (!bs.saferead_bool(taunting)) return;
		Actor::DeserializeTick(bs);
	}
}
