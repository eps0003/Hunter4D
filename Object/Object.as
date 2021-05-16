#include "ObjectCommon.as"

class Object
{
    CPlayer@ player;
    Vec2f position;
    Vec2f velocity;
    private float _radius;

    Object(CPlayer@ player, Vec2f position, float radius)
    {
        @this.player = player;
        this.position = position;
        this.radius = radius;
    }

    Object(CBitStream@ bs)
    {
        @player = getPlayerByNetworkId(bs.read_netid());
        position = bs.read_Vec2f();
        velocity = bs.read_Vec2f();
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
        bs.write_Vec2f(position);
        bs.write_Vec2f(velocity);
        bs.write_f32(radius);
    }

    void SerializeTick(CBitStream@ bs)
    {
        bs.write_netid(player.getNetworkID());
        bs.write_Vec2f(position);
        bs.write_Vec2f(velocity);
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

    void Render()
    {
        CTeam@ team = getRules().getTeam(teamNum);
        SColor col = team !is null ? team.color : color_white;
        GUI::DrawCircle(position, radius, col);
    }
}
