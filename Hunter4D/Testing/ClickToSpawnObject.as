#include "Ray.as"
#include "Camera.as"
#include "Blob.as"

void onInit(CRules@ this)
{
	this.addCommandID("spawn object");
}

void onRestart(CRules@ this)
{
	this.RemoveScript("ClickToSpawnObject.as");
}

void onTick(CRules@ this)
{
	if (isClient() && getControls().isKeyJustPressed(KEY_LBUTTON))
	{
		Camera@ camera = Camera::getCamera();
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
	if (isServer() && cmd == this.getCommandID("spawn object"))
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
