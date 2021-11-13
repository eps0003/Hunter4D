#include "Model.as"

shared class HumanModel : Model
{
	HumanModel(string texture, float scale)
	{
		super(scale);

		ModelSegment@ body = ModelSegment("ActorBody.obj", texture);
		ModelSegment@ head = ModelSegment("ActorHead.obj", texture);
		ModelSegment@ upperLeftArm = ModelSegment("ActorUpperLeftArm.obj", texture);
		ModelSegment@ lowerLeftArm = ModelSegment("ActorLowerLeftArm.obj", texture);
		ModelSegment@ upperRightArm = ModelSegment("ActorUpperRightArm.obj", texture);
		ModelSegment@ lowerRightArm = ModelSegment("ActorLowerRightArm.obj", texture);
		ModelSegment@ upperLeftLeg = ModelSegment("ActorUpperLeftLeg.obj", texture);
		ModelSegment@ lowerLeftLeg = ModelSegment("ActorLowerLeftLeg.obj", texture);
		ModelSegment@ upperRightLeg = ModelSegment("ActorUpperRightLeg.obj", texture);
		ModelSegment@ lowerRightLeg = ModelSegment("ActorLowerRightLeg.obj", texture);

		AddSegment("body", body);
		AddSegment("head", head);
		AddSegment("upperLeftArm", upperLeftArm);
		AddSegment("lowerLeftArm", lowerLeftArm);
		AddSegment("upperRightArm", upperRightArm);
		AddSegment("lowerRightArm", lowerRightArm);
		AddSegment("upperLeftLeg", upperLeftLeg);
		AddSegment("lowerLeftLeg", lowerLeftLeg);
		AddSegment("upperRightLeg", upperRightLeg);
		AddSegment("lowerRightLeg", lowerRightLeg);

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
}
