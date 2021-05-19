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
			CControls@ controls = getControls();
			if (controls.isKeyPressed(KEY_KEY_W))
			{
				position.z += 1.0f;
			}
			if (controls.isKeyPressed(KEY_KEY_S))
			{
				position.z -= 1.0f;
			}
			if (controls.isKeyPressed(KEY_KEY_D))
			{
				position.x += 1.0f;
			}
			if (controls.isKeyPressed(KEY_KEY_A))
			{
				position.x -= 1.0f;
			}
			if (controls.isKeyPressed(KEY_SPACE))
			{
				position.y += 1.0f;
			}
			if (controls.isKeyPressed(KEY_LSHIFT))
			{
				position.y -= 1.0f;
			}

			Camera@ camera = Camera::getCamera();
			Mouse@ mouse = Mouse::getMouse();

			camera.position = position;
			camera.rotation = camera.rotation + Vec3f(mouse.velocity.y, mouse.velocity.x, 0);
		}
	}
}