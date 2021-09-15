#include "Model.as"
#include "Camera.as"
#include "Skins.as"

shared class SoccerBallModel : Model
{
    Object@ object;

	SoccerBallModel(Object@ object)
	{
		super(2.0f);
		@this.object = object;

		AddSegment(ModelSegment("SoccerBall.obj", "Colors.png"));
	}

	void Update()
	{
		Model::Update();
		Matrix::SetTranslation(matrix, object.interPosition.x, object.interPosition.y, object.interPosition.z);
		Matrix::SetRotationDegrees(matrix, -object.interRotation.x, -object.interRotation.y, -object.interRotation.z);
	}
}
