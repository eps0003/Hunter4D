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
		SetCollisionFlags(CollisionFlag::Blocks);
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

	void DeserializeInit(CBitStream@ bs)
	{
		Object::DeserializeInit(bs);
		@this.player = getPlayerByNetworkId(bs.read_netid());
	}

	void DeserializeTick(CBitStream@ bs)
	{
		Object::DeserializeTick(bs);
		@this.player = getPlayerByNetworkId(bs.read_netid());
	}

	void HandleSerializeInit(CPlayer@ player)
	{
		// Sync to player if it isn't my player
		if (this.player !is player)
		{
			CBitStream bs;
			SerializeInit(bs);
			getRules().SendCommand(getRules().getCommandID("init actor"), bs, player);
		}
	}

	void HandleSerializeTick()
	{
		// Sync to server if not localhost
		if (!isServer())
		{
			// Sync my actor
			Actor@ actor = Actor::getMyActor();
			if (actor !is null)
			{
				CBitStream bs;
				SerializeTick(bs);
				getRules().SendCommand(getRules().getCommandID("sync actor"), bs, true);
			}
		}
	}

	void HandleDeserializeInit(CBitStream@ bs)
	{
		if (!isClient()) return;

		DeserializeInit(bs);
		Actor::SetActor(player, this);
	}

	void HandleDeserializeTick(CBitStream@ bs)
	{
		DeserializeTick(bs);

		// Don't update my own actor
		if (player.isMyPlayer()) return;

		// Update actor
		Actor@ oldActor = Actor::getActor(player);
		if (oldActor !is null)
		{
			oldActor = this;
		}
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
			oldPosition = position;
			oldVelocity = velocity;

			Movement();
			Collision();
			UpdateCamera();
		}
	}

	void Render()
	{
		if (!player.isMyPlayer())
		{
			Object::Render();
		}
		else
		{
			Interpolate();
		}
	}

	private void Movement()
	{
		CControls@ controls = getControls();
		Camera@ camera = Camera::getCamera();

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
		velocity.x = dir.x;
		velocity.z = dir.y;
		velocity.y = verticalDir;
	}

	private void UpdateCamera()
	{
		Camera@ camera = Camera::getCamera();
		Mouse@ mouse = Mouse::getMouse();

		// Move and rotate camera
		camera.position = position;
		camera.rotation = camera.rotation + Vec3f(mouse.velocity.y, mouse.velocity.x, 0);
		camera.rotation = Vec3f(
			Maths::Clamp(camera.rotation.x, -90, 90),
			camera.rotation.y,
			Maths::Clamp(camera.rotation.z, -90, 90)
		);
	}
}
