#include "IAnimation.as"
#include "ActorModel.as"

shared class ActorJumpAnim : IAnimation
{
	private ActorModel@ model;
	private Actor@ actor;

	float maxHeadAngle = 60.0f;

	ActorJumpAnim(ActorModel@ model)
	{
		@this.model = model;
		@actor = model.actor;
	}

	void Update()
	{
		float gt = Interpolation::getGameTime() * 0.05f;

		// Body

		model.body.position = Vec3f(0, 0.75f, 0);

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
		model.upperLeftArm.rotation = Vec3f(-20, 0, 20);

		model.lowerLeftArm.position = Vec3f(-0.125f, -0.375f, -0.125f);
		model.lowerLeftArm.rotation = Vec3f(40, 0, 0);

		// Right arm

		model.upperRightArm.position = Vec3f(0.25f, 0.75f, 0);
		model.upperRightArm.rotation = Vec3f(-20, 0, -20);

		model.lowerRightArm.position = Vec3f(0.125f, -0.375f, -0.125f);
		model.lowerRightArm.rotation = Vec3f(40, 0, 0);

		// Left leg

		model.upperLeftLeg.position = Vec3f();
		model.upperLeftLeg.rotation = Vec3f(45, 10, 0);

		model.lowerLeftLeg.position = Vec3f(-0.125f, -0.375f, 0.125f);
		model.lowerLeftLeg.rotation = Vec3f(-45, 0, 0);

		// Right leg

		model.upperRightLeg.position = Vec3f();
		model.upperRightLeg.rotation = Vec3f(20, -10, 0);

		model.lowerRightLeg.position = Vec3f(0.125f, -0.375f, 0.125f);
		model.lowerRightLeg.rotation = Vec3f(-45, 0, 0);
	}
}
