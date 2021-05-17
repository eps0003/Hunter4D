#include "ObjectCommon.as"
#include "Vec3f.as"
#include "Camera.as"

class Object
{
    Vec3f position;
    Vec3f velocity;

    Object(Vec3f position)
    {
        this.position = position;
    }

    Object(CBitStream@ bs)
    {
        position = Vec3f(bs);
        velocity = Vec3f(bs);
    }

    void opAssign(Object object)
    {
        position = object.position;
        velocity = object.velocity;
    }

    void SerializeInit(CBitStream@ bs)
    {
        position.Serialize(bs);
        velocity.Serialize(bs);
    }

    void SerializeTick(CBitStream@ bs)
    {
        position.Serialize(bs);
        velocity.Serialize(bs);
    }

    void Update()
    {

    }

    void Render()
    {
        Vertex[] vertices = {
            Vertex(-1,  1, 10, 0, 0, color_white),
            Vertex( 1,  1, 10, 1, 0, color_white),
            Vertex( 1, -1, 10, 1, 1, color_white),
            Vertex(-1, -1, 10, 0, 1, color_white)
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
