#include "Model.as"
#include "Camera.as"
#include "ActorRunAnim.as"
#include "Skins.as"

shared class ActorModel : Model
{
	Actor@ actor;

	ModelSegment@ body;
	ModelSegment@ head;
	ModelSegment@ upperLeftArm;
	ModelSegment@ lowerLeftArm;
	ModelSegment@ upperRightArm;
	ModelSegment@ lowerRightArm;
	ModelSegment@ upperLeftLeg;
	ModelSegment@ lowerLeftLeg;
	ModelSegment@ upperRightLeg;
	ModelSegment@ lowerRightLeg;

	ActorModel(Actor@ actor)
	{
		super(0.9f * actor.getScale());
		@this.actor = actor;

		string texture = Skins::getSkinName(actor.getPlayer());

		@body = ModelSegment("ActorBody.obj", texture);
		@head = ModelSegment("ActorHead.obj", texture);
		@upperLeftArm = ModelSegment("ActorUpperLeftArm.obj", texture);
		@lowerLeftArm = ModelSegment("ActorLowerLeftArm.obj", texture);
		@upperRightArm = ModelSegment("ActorUpperRightArm.obj", texture);
		@lowerRightArm = ModelSegment("ActorLowerRightArm.obj", texture);
		@upperLeftLeg = ModelSegment("ActorUpperLeftLeg.obj", texture);
		@lowerLeftLeg = ModelSegment("ActorLowerLeftLeg.obj", texture);
		@upperRightLeg = ModelSegment("ActorUpperRightLeg.obj", texture);
		@lowerRightLeg = ModelSegment("ActorLowerRightLeg.obj", texture);

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

		AddAnimation("idle", ActorIdleAnim(this));
		AddAnimation("run", ActorRunAnim(this));
		AddAnimation("jump", ActorJumpAnim(this));
		AddAnimation("taunt", ActorJumpingJacksAnim(this));

		SetAnimation("idle");
	}

	void Update()
	{
		Model::Update();
		Matrix::SetTranslation(matrix, actor.interPosition.x, actor.interPosition.y, actor.interPosition.z);
	}
}