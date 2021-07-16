#include "Model.as"
#include "Camera.as"
#include "ActorRunAnim.as"

shared class ActorModel : Model
{
	Actor@ actor;

	ModelSegment@ body = ModelSegment("ActorBody.obj");
	ModelSegment@ head = ModelSegment("ActorHead.obj");
	ModelSegment@ upperLeftArm = ModelSegment("ActorUpperLeftArm.obj");
	ModelSegment@ lowerLeftArm = ModelSegment("ActorLowerLeftArm.obj");
	ModelSegment@ upperRightArm = ModelSegment("ActorUpperRightArm.obj");
	ModelSegment@ lowerRightArm = ModelSegment("ActorLowerRightArm.obj");
	ModelSegment@ upperLeftLeg = ModelSegment("ActorUpperLeftLeg.obj");
	ModelSegment@ lowerLeftLeg = ModelSegment("ActorLowerLeftLeg.obj");
	ModelSegment@ upperRightLeg = ModelSegment("ActorUpperRightLeg.obj");
	ModelSegment@ lowerRightLeg = ModelSegment("ActorLowerRightLeg.obj");

	ActorModel(Actor@ actor, string texture)
	{
		super(texture, 0.9f);
		@this.actor = actor;

		AddSegment(body);
		AddSegment(head);
		AddSegment(upperLeftArm);
		AddSegment(lowerLeftArm);
		AddSegment(upperRightArm);
		AddSegment(lowerRightArm);
		AddSegment(upperLeftLeg);
		AddSegment(lowerLeftLeg);
		AddSegment(upperRightLeg);
		AddSegment(lowerRightLeg);

		body.AddChild(head);
		body.AddChild(upperLeftArm);
		body.AddChild(upperRightArm);
		body.AddChild(upperLeftLeg);
		body.AddChild(upperRightLeg);

		upperLeftArm.AddChild(lowerLeftArm);
		upperRightArm.AddChild(lowerRightArm);
		upperLeftLeg.AddChild(lowerLeftLeg);
		upperRightLeg.AddChild(lowerRightLeg);
	}

	void Update()
	{
		Model::Update();
		Matrix::SetTranslation(matrix, actor.interPosition.x, actor.interPosition.y, actor.interPosition.z);
	}
}