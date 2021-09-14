#include "Model.as"
#include "Camera.as"

shared class GunModel : Model
{
	HunterActor@ actor;

	ModelSegment@ gun;

	GunModel(HunterActor@ actor)
	{
		super(0.025f);
		@this.actor = actor;

		@gun = ModelSegment("AK47.obj", "AK47.png");
		AddSegment(gun);
	}

	void Update()
	{
		Model::Update();

		Matrix::Multiply(actor.model.lowerRightArm.matrix, matrix, matrix);

		float[] m;
		Matrix::MakeIdentity(m);
		Matrix::SetRotationDegrees(m, 90, 0, 0);
		Matrix::SetTranslation(m, 0, 0.05f * -5, 0.05f * 7);
		Matrix::MultiplyImmediate(matrix, m);
	}
}
