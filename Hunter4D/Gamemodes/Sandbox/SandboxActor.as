#include "Actor.as"
#include "Ray.as"

class SandboxActor : Actor
{
	private CControls@ controls;
	private Mouse@ mouse;
	private Camera@ camera;
	private Map@ map;

	float acceleration = 0.08f;
	float friction = 0.3f;
	float jumpForce = 0.3f;

	SandboxActor(CPlayer@ player, Vec3f position)
	{
		super(player, position);

		SetInitCommand("init sandbox actor");
		SetCollider(AABB(Vec3f(-0.3f, -1.6f, -0.3f), Vec3f(0.3f, 0.1f, 0.3f)));
		SetCollisionFlags(CollisionFlag::All);
		SetGravity(Vec3f(0, -0.04f, 0));
	}

	void OnInit()
	{
		Actor::OnInit();

		if (player.isMyPlayer())
		{
			@controls = getControls();
			@mouse = Mouse::getMouse();
			@camera = Camera::getCamera();
			@map = Map::getMap();
		}
	}

	void Update()
	{
		Actor::Update();

		if (player.isMyPlayer())
		{
			Movement();
			BlockPlacement();
		}
	}

	private void Movement()
	{
		CControls@ controls = getControls();
		Camera@ camera = Camera::getCamera();

		Vec2f dir;
		s8 verticalDir = 0;

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

		velocity += gravity;

		if (controls.ActionKeyPressed(AK_ACTION3) && isOnGround())
		{
			velocity.y = jumpForce;
		}

		// Move actor
		velocity.x += dir.x * acceleration - friction * velocity.x;
		velocity.z += dir.y * acceleration - friction * velocity.z;
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
			map.ClientSetBlockSafe(position, SColor(255, 100, 100, 100));
		}
		else
		{
			Vec3f position = raycast.hitWorldPos;
			map.ClientSetBlockSafe(position, 0);
		}
	}
}
