#include "IAnimation.as"
#include "ActorModel.as"

shared class ActorJumpingJacksAnim : IAnimation
{
	private ActorModel@ model;
	private Actor@ actor;

	float maxHeadAngle = 60.0f;

	ActorJumpingJacksAnim(ActorModel@ model)
	{
		@this.model = model;
		@actor = model.actor;
	}

	void Update()
	{
		float gt = (Interpolation::getGameTime() - model.animStartTime) * 0.25f + Maths::Pi;
		float sin = Maths::Sin(gt);
		float cos = Maths::Cos(gt);

		// Body

		model.body.position = Vec3f(0, 0.75f + Maths::Abs(sin) * 0.3f - (cos + 1) * 0.05f, 0);

		float diff = Maths::AngleDifference(actor.interRotation.y, model.body.rotation.y);
		if (Maths::Abs(diff) > maxHeadAngle)
		{
			model.body.rotation = Vec3f(0, actor.interRotation.y + maxHeadAngle * Maths::Sign(diff), 0);
		}

		// Head

		model.head.position = Vec3f(0, 0.75f, 0);
		model.head.rotation = actor.interRotation + Vec3f(0, -model.body.rotation.y, 0);

		// Left arm

		model.upperLeftArm.position = Vec3f(-0.25f, 0.75f, 0);
		model.upperLeftArm.rotation = Vec3f(0, (cos + 1) * 45, (cos + 1) * 70);

		model.lowerLeftArm.position = Vec3f(-0.125f, -0.375f, -0.125f);
		model.lowerLeftArm.rotation = Vec3f((cos + 1) * 20, 0, 0);

		// Right arm

		model.upperRightArm.position = Vec3f(0.25f, 0.75f, 0);
		model.upperRightArm.rotation = Vec3f(0, (cos + 1) * -45, (cos + 1) * -70);

		model.lowerRightArm.position = Vec3f(0.125f, -0.375f, -0.125f);
		model.lowerRightArm.rotation = Vec3f((cos + 1) * 20, 0, 0);

		// Left leg

		model.upperLeftLeg.position = Vec3f();
		model.upperLeftLeg.rotation = Vec3f(0, 0, (cos + 1) * 10);

		model.lowerLeftLeg.position = Vec3f(-0.125f, -0.375f, 0.125f);
		model.lowerLeftLeg.rotation = Vec3f();

		// Right leg

		model.upperRightLeg.position = Vec3f();
		model.upperRightLeg.rotation = Vec3f(0, 0, (cos + 1 )* -10);

		model.lowerRightLeg.position = Vec3f(0.125f, -0.375f, 0.125f);
		model.lowerRightLeg.rotation = Vec3f();
	}
}
