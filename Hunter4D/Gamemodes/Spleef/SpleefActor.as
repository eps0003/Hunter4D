#include "Actor.as"
#include "Ray.as"

class SpleefActor : Actor
{
	private CControls@ controls;
	private Mouse@ mouse;
	private Camera@ camera;
	private Map@ map;

	SpleefActor(CPlayer@ player, Vec3f position)
	{
		super(player, position);
		SetInitCommand("init spleef actor");
	}

	void OnInit()
	{
		Actor::OnInit();

		if (isClient())
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

		if (isClient() && canDestroyBlocks())
		{
			bool left = controls.ActionKeyPressed(AK_ACTION1);
			bool right = controls.ActionKeyPressed(AK_ACTION2);

			if (left || right)
			{
				Ray ray(camera.position, camera.rotation.dir());

				RaycastInfo raycast;
				if (ray.raycastBlock(6, false, raycast))
				{
					Vec3f position = raycast.hitWorldPos;
					map.ClientSetBlockSafe(position, 0);
				}
			}
		}
	}

	bool canDestroyBlocks()
	{
		return mouse.isInControl() && rules.getCurrentState() != WARMUP;
	}
}
