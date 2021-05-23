#include "ObjectCommon.as"
#include "Vec3f.as"
#include "Camera.as"

class Object
{
	u16 id = 0;

	Vec3f position;
	Vec3f oldPosition;
	Vec3f interPosition;

	Vec3f velocity;
	Vec3f oldVelocity;
	Vec3f interVelocity;

	Object(Vec3f position)
	{
		this.position = position;
	}

	Object(CBitStream@ bs)
	{
		id = bs.read_u16();
		position = Vec3f(bs);
		oldPosition = position;
		velocity = Vec3f(bs);
		oldVelocity = velocity;
	}

	void opAssign(Object object)
	{
		oldPosition = position;
		position = object.position;
		oldVelocity = velocity;
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
		oldPosition = position;
		oldVelocity = velocity;
	}

	void Render()
	{
		float[] matrix;
		Matrix::MakeIdentity(matrix);
		Matrix::SetTranslation(matrix, interPosition.x, interPosition.y, interPosition.z);
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

	void Interpolate()
	{
		float t = Interpolation::getFrameTime();
		interPosition = oldPosition.lerp(position, t);
		interVelocity = oldVelocity.lerp(velocity, t);
	}
}
