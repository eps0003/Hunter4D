#include "IAnimation.as"
#include "ActorModel.as"

class ActorFlossAnim : IAnimation
{
	private ActorModel@ model;
	private Actor@ actor;

	float maxHeadAngle = 60.0f;

	ActorFlossAnim(ActorModel@ model)
	{
		@this.model = model;
		@actor = model.actor;
	}

	void Update()
	{
		float gt = Interpolation::getGameTime() * 0.13f;
		float sin = Maths::Sin(gt);
		float sin2 = Maths::Sin(gt * 3);

		// Body

		model.body.position = Vec3f(0, 0.75f, 0);

		// float diff = Maths::AngleDifference(actor.interRotation.y, model.body.rotation.y);
		// if (Maths::Abs(diff) > maxHeadAngle)
		// {
		// 	model.body.rotation = Vec3f(0, actor.interRotation.y + maxHeadAngle * Maths::Sign(diff), 0);
		// }

		Vec2f vec = Vec2f_lengthdir(sin2, model.body.rotation.y);
		model.body.position += Vec3f(vec.x, 0, vec.y) * 0.1f;
		model.body.rotation.z = sin2 * -6;

		// Head

		model.head.position = Vec3f(0, 0.75f, 0);
		// model.head.rotation = actor.interRotation + Vec3f(0, -model.body.rotation.y, -model.body.rotation.z);
		model.head.rotation = Vec3f(0, -model.body.rotation.y, -model.body.rotation.z);

		// Left arm

		model.upperLeftArm.position = Vec3f(-0.25f, 0.75f, 0);
		model.upperLeftArm.rotation = Vec3f();
		model.upperLeftArm.rotation.x = (Maths::Pow(sin, 4) - 0.5f) * -50.0f;
		model.upperLeftArm.rotation.z = sin2 * 50;

		model.lowerLeftArm.position = Vec3f(-0.125f, -0.375f, -0.125f);
		model.lowerLeftArm.rotation = Vec3f();

		// Right arm

		model.upperRightArm.position = Vec3f(0.25f, 0.75f, 0);
		model.upperRightArm.rotation = Vec3f();
		model.upperRightArm.rotation.x = (Maths::Pow(sin, 4) - 0.5f) * -50.0f;
		model.upperRightArm.rotation.z = sin2 * 50;

		model.lowerRightArm.position = Vec3f(0.125f, -0.375f, -0.125f);
		model.lowerRightArm.rotation = Vec3f();

		// Left leg

		model.upperLeftLeg.position = Vec3f();
		model.upperLeftLeg.rotation = Vec3f();
		model.upperLeftLeg.rotation.z = 16 + (sin2 - 1) * 12;

		model.lowerLeftLeg.position = Vec3f(-0.125f, -0.375f, 0.125f);
		model.lowerLeftLeg.rotation = Vec3f();

		// Right leg

		model.upperRightLeg.position = Vec3f();
		model.upperRightLeg.rotation = Vec3f();
		model.upperRightLeg.rotation.z = -16 + (sin2 + 1) * 12;

		model.lowerRightLeg.position = Vec3f(0.125f, -0.375f, 0.125f);
		model.lowerRightLeg.rotation = Vec3f();
	}
}
