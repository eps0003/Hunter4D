#include "ObjectCommon.as"
#include "Vec3f.as"
#include "Camera.as"

class Object
{
	u16 id = 0;
	Vec3f position;
	Vec3f velocity;

	Object(Vec3f position)
	{
		this.position = position;
	}

	Object(CBitStream@ bs)
	{
		id = bs.read_u16();
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
		bs.write_u16(id);
		position.Serialize(bs);
		velocity.Serialize(bs);
	}

	void SerializeTick(CBitStream@ bs)
	{
		bs.write_u16(id);
		position.Serialize(bs);
		velocity.Serialize(bs);
	}

	void Update()
	{

	}

	void Render()
	{
		float[] matrix;
		Matrix::MakeIdentity(matrix);
		Matrix::SetTranslation(matrix, position.x, position.y, position.z);
		Render::SetModelTransform(matrix);

		Vertex[] vertices = {
			Vertex(-1,  1, 0, 0, 0, color_white),
			Vertex( 1,  1, 0, 1, 0, color_white),
			Vertex( 1, -1, 0, 1, 1, color_white),
			Vertex(-1, -1, 0, 0, 1, color_white)
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
