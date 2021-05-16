#include "ObjectCommon.as"
#include "Vec3f.as"
#include "Camera.as"

class Object
{
    CPlayer@ player;
    Vec3f position;
    Vec3f velocity;
    private float _radius;

    Object(CPlayer@ player, Vec3f position, float radius)
    {
        @this.player = player;
        this.position = position;
        this.radius = radius;
    }

    Object(CBitStream@ bs)
    {
        @player = getPlayerByNetworkId(bs.read_netid());
        position = Vec3f(bs);
        velocity = Vec3f(bs);
        radius = bs.read_f32();
    }

    void opAssign(Object object)
    {
        position = object.position;
        velocity = object.velocity;
    }

    void SerializeInit(CBitStream@ bs)
    {
        bs.write_netid(player.getNetworkID());
        position.Serialize(bs);
        velocity.Serialize(bs);
        bs.write_f32(radius);
    }

    void SerializeTick(CBitStream@ bs)
    {
        bs.write_netid(player.getNetworkID());
        position.Serialize(bs);
        velocity.Serialize(bs);
    }

    float radius
    {
        get const
        {
            return _radius;
        }
        set
        {
            _radius = value;

            if (!isClient())
            {
                CBitStream bs;
                bs.write_netid(player.getNetworkID());
                bs.write_f32(_radius);
                getRules().SendCommand(getRules().getCommandID("set object radius"), bs, true);
            }
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
        // if (isClient())
        // {
        //     CControls@ controls = getControls();
        //     if (controls.isKeyPressed(KEY_KEY_W))
        //     {
        //         position.z += 1.0f;
        //     }
        //     if (controls.isKeyPressed(KEY_KEY_S))
        //     {
        //         position.z -= 1.0f;
        //     }
        // }

        if (isServer())
        {
            position.z = Maths::Sin(getGameTime() / 10.0f) * 10.0f;
        }

        if (isClient())
        {
            Camera@ camera = Camera::getCamera();
            camera.position = position;
        };
    }

    void Render()
    {
        CTeam@ team = getRules().getTeam(teamNum);
        SColor col = team !is null ? team.color : color_white;

        Vertex[] vertices = {
            Vertex(-1,  1, 10, 0, 0, col),
            Vertex( 1,  1, 10, 1, 0, col),
            Vertex( 1, -1, 10, 1, 1, col),
            Vertex(-1, -1, 10, 0, 1, col)
        };

		Render::SetBackfaceCull(false);
		Render::SetAlphaBlend(true);
		Render::RawQuads("pixel", vertices);
		Render::SetAlphaBlend(false);
		Render::SetBackfaceCull(true);
    }

    void RenderHUD()
    {
        GUI::DrawText("Position: " + position.toString(), Vec2f(10, 10), color_black);
    }
}
