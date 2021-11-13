#include "IAnimation.as"
#include "ActorModel.as"

shared class ActorRunAnim : IAnimation
{
	private ActorModel@ model;
	private Actor@ actor;

	private ModelSegment@ body;
	private ModelSegment@ head;
	private ModelSegment@ upperLeftArm;
	private ModelSegment@ upperRightArm;
	private ModelSegment@ lowerLeftArm;
	private ModelSegment@ lowerRightArm;
	private ModelSegment@ upperLeftLeg;
	private ModelSegment@ upperRightLeg;
	private ModelSegment@ lowerLeftLeg;
	private ModelSegment@ lowerRightLeg;

	float maxHeadAngle = 60.0f;

	ActorRunAnim(ActorModel@ model)
	{
		@this.model = model;
		@actor = model.actor;

		@body = model.getSegment("body");
		@head = model.getSegment("head");
		@upperLeftArm = model.getSegment("upperLeftArm");
		@upperRightArm = model.getSegment("upperRightArm");
		@lowerLeftArm = model.getSegment("lowerLeftArm");
		@lowerRightArm = model.getSegment("lowerRightArm");
		@upperLeftLeg = model.getSegment("upperLeftLeg");
		@upperRightLeg = model.getSegment("upperRightLeg");
		@lowerLeftLeg = model.getSegment("lowerLeftLeg");
		@lowerRightLeg = model.getSegment("lowerRightLeg");
	}

	void Update()
	{
		float gt = Interpolation::getGameTime() * 0.4f;
		float vel = actor.interVelocity.toXZ().Length() * 3.0f;

		float sin = Maths::Sin(gt) * vel;
		float cos = Maths::Cos(gt) * vel;

		float limbSin = sin * 40.0f;
		float limbCos = cos * 40.0f;

		// Body

		body.position = Vec3f(0, 0.75f + Maths::Abs(cos * 0.1f) * vel * 1.5f, 0);
		body.rotation = Vec3f(-4.0f * vel + Maths::Sin(gt * 2.0f) * vel * -4.0f, -actor.interVelocity.toXZ().Angle() - 90, 0);

		float diff = Maths::AngleDifference(actor.interRotation.y, body.rotation.y);
		if (Maths::Abs(diff) > maxHeadAngle)
		{
			body.rotation.y = actor.interRotation.y + maxHeadAngle * Maths::Sign(diff);
		}

		// Head

		head.position = Vec3f(0, 0.75f, 0);
		head.rotation = actor.interRotation + Vec3f(Maths::Sin(gt * 2.0f) * vel * 4.0f, -body.rotation.y, 0);

		// Left arm

		upperLeftArm.position = Vec3f(-0.25f, 0.75f, 0);
		upperLeftArm.rotation = Vec3f(-limbCos, 0, 0);

		lowerLeftArm.position = Vec3f(-0.125f, -0.375f, -0.125f);
		lowerLeftArm.rotation = Vec3f(Maths::Max(0, -limbCos), 0, 0);

		// Right arm

		upperRightArm.position = Vec3f(0.25f, 0.75f, 0);
		upperRightArm.rotation = Vec3f(limbCos, 0, 0);

		lowerRightArm.position = Vec3f(0.125f, -0.375f, -0.125f);
		lowerRightArm.rotation = Vec3f(Maths::Max(0, limbCos), 0, 0);

		// Left leg

		upperLeftLeg.position = Vec3f();
		upperLeftLeg.rotation = Vec3f(limbCos, 0, 0);

		lowerLeftLeg.position = Vec3f(-0.125f, -0.375f, 0.125f);
		lowerLeftLeg.rotation = Vec3f(Maths::Min(0, limbSin), 0, 0);

		// Right leg

		upperRightLeg.position = Vec3f();
		upperRightLeg.rotation = Vec3f(-limbCos, 0, 0);

		lowerRightLeg.position = Vec3f(0.125f, -0.375f, 0.125f);
		lowerRightLeg.rotation = Vec3f(Maths::Min(0, -limbSin), 0, 0);
	}
}
