#include "IAnimation.as"
#include "ActorModel.as"

shared class ActorRunAnim : IAnimation
{
	private ActorModel@ model;
	private Actor@ actor;

	float maxHeadAngle = 60.0f;

	ActorRunAnim(ActorModel@ model)
	{
		@this.model = model;
		@actor = model.actor;
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

		model.body.position = Vec3f(0, 0.75f + Maths::Abs(cos * 0.1f) * vel * 1.5f, 0);
		model.body.rotation = Vec3f(-4.0f * vel + Maths::Sin(gt * 2.0f) * vel * -4.0f, -actor.interVelocity.toXZ().Angle() - 90, 0);

		float diff = Maths::AngleDifference(actor.interRotation.y, model.body.rotation.y);
		if (Maths::Abs(diff) > maxHeadAngle)
		{
			model.body.rotation.y = actor.interRotation.y + maxHeadAngle * Maths::Sign(diff);
		}

		// Head

		model.head.position = Vec3f(0, 0.75f, 0);
		model.head.rotation = actor.interRotation + Vec3f(Maths::Sin(gt * 2.0f) * vel * 4.0f, -model.body.rotation.y, 0);

		// Left arm

		model.upperLeftArm.position = Vec3f(-0.25f, 0.75f, 0);
		model.upperLeftArm.rotation = Vec3f(-limbCos, 0, 0);

		model.lowerLeftArm.position = Vec3f(-0.125f, -0.375f, -0.125f);
		model.lowerLeftArm.rotation = Vec3f(Maths::Max(0, -limbCos), 0, 0);

		// Right arm

		model.upperRightArm.position = Vec3f(0.25f, 0.75f, 0);
		model.upperRightArm.rotation = Vec3f(limbCos, 0, 0);

		model.lowerRightArm.position = Vec3f(0.125f, -0.375f, -0.125f);
		model.lowerRightArm.rotation = Vec3f(Maths::Max(0, limbCos), 0, 0);

		// Left leg

		model.upperLeftLeg.position = Vec3f();
		model.upperLeftLeg.rotation = Vec3f(limbCos, 0, 0);

		model.lowerLeftLeg.position = Vec3f(-0.125f, -0.375f, 0.125f);
		model.lowerLeftLeg.rotation = Vec3f(Maths::Min(0, limbSin), 0, 0);

		// Right leg

		model.upperRightLeg.position = Vec3f();
		model.upperRightLeg.rotation = Vec3f(-limbCos, 0, 0);

		model.lowerRightLeg.position = Vec3f(0.125f, -0.375f, 0.125f);
		model.lowerRightLeg.rotation = Vec3f(Maths::Min(0, -limbSin), 0, 0);
	}
}
