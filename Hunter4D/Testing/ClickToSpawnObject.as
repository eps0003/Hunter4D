#include "Ray.as"
#include "Camera.as"
#include "Blob.as"

Mouse@ mouse;
Camera@ camera;
CControls@ controls;

void onInit(CRules@ this)
{
	this.addCommandID("spawn object");

	onRestart(this);
}

void onRestart(CRules@ this)
{
	if (isClient())
	{
		@mouse = Mouse::getMouse();
		@camera = Camera::getCamera();
		@controls = getControls();
	}
}

void onTick(CRules@ this)
{
	if (!isClient() || !mouse.isInControl()) return;

	if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_ACTION1)))
	{
		Ray ray(camera.position, camera.rotation.dir());

		RaycastInfo raycast;
		if (ray.raycastBlock(10, false, raycast))
		{
			Vec3f position = raycast.hitPos + raycast.normal;

			if (isServer())
			{
				SpawnObject(position);
			}
			else
			{
				CBitStream bs;
				position.Serialize(bs);
				this.SendCommand(this.getCommandID("spawn object"), bs, false);
			}
		}
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isClient() && cmd == this.getCommandID("spawn object"))
	{
		Vec3f position;
		if (!position.deserialize(params)) return;

		SpawnObject(position);
	}
}

void SpawnObject(Vec3f position)
{
	Object::AddObject(Blob(position));
}
