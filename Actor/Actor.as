#include "Object.as"
#include "ActorCommon.as"
#include "Mouse.as"

class Actor : Object
{
	CPlayer@ player;

	Actor(CPlayer@ player, Vec3f position)
	{
		super(position);
		@this.player = player;
	}

	Actor(CBitStream@ bs)
	{
		super(bs);
		@this.player = getPlayerByNetworkId(bs.read_netid());
	}

	void opAssign(Actor actor)
	{
		opAssign(cast<Object>(actor));
	}

	void SerializeInit(CBitStream@ bs)
	{
		Object::SerializeInit(bs);
		bs.write_netid(player.getNetworkID());
	}

	void SerializeTick(CBitStream@ bs)
	{
		Object::SerializeTick(bs);
		bs.write_netid(player.getNetworkID());
	}

	u8 teamNum
	{
		get const
		{
			return player.getTeamNum();
		}
		set
		{
			player.server_setTeamNum(value);
		}
	}

	void Update()
	{
		if (player.isMyPlayer())
		{
			Movement();
		}
	}

	void Render()
	{
		if (!player.isMyPlayer())
		{
			Object::Render();
		}
	}

	private void Movement()
	{
		CControls@ controls = getControls();
		Camera@ camera = Camera::getCamera();
		Mouse@ mouse = Mouse::getMouse();

		Vec2f dir;
		s8 verticalDir = 0;

		if (controls.isKeyPressed(KEY_KEY_W)) dir.y++;
		if (controls.isKeyPressed(KEY_KEY_S)) dir.y--;
		if (controls.isKeyPressed(KEY_KEY_D)) dir.x++;
		if (controls.isKeyPressed(KEY_KEY_A)) dir.x--;

		if (controls.isKeyPressed(KEY_SPACE)) verticalDir++;
		if (controls.isKeyPressed(KEY_LSHIFT)) verticalDir--;

		float len = dir.Length();
		if (len > 0)
		{
			dir /= len; // Normalize
			dir = dir.RotateBy(camera.rotation.y);
		}

		// Move actor
		position.x += dir.x;
		position.z += dir.y;
		position.y += verticalDir;

		// Move and rotate camera
		camera.position = position;
		camera.rotation = camera.rotation + Vec3f(mouse.velocity.y, mouse.velocity.x, 0);
	}
}