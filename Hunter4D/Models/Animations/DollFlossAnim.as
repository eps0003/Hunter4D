#include "IAnimation.as"
#include "HumanModel.as"
#include "Camera.as"

shared class DollFlossAnim : IAnimation
{
	private HumanModel@ model;
	private Doll@ doll;

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

	DollFlossAnim(HumanModel@ model, Doll@ doll)
	{
		@this.model = model;
		@this.doll = doll;

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
		float gt = Interpolation::getGameTime() * 0.13f;
		float sin = Maths::Sin(gt);
		float sin2 = Maths::Sin(gt * 3);

		// Body

		body.position = Vec3f(0, 0.75f, 0);

		Vec2f vec = Vec2f_lengthdir(sin2, body.rotation.y);
		body.position += Vec3f(vec.x, 0, vec.y) * 0.1f;
		body.rotation.z = sin2 * -6;

		// Head

		head.position = Vec3f(0, 0.75f, 0);
		head.rotation = Vec3f();

		Camera@ camera = Camera::getCamera();
		if (camera !is null)
		{
			Vec3f dollHeadPos = doll.interPosition + Vec3f(0, doll.eyeHeight, 0);
			Vec3f lookDir = (camera.interPosition - dollHeadPos).normalized();

			head.rotation.y = Maths::toDegrees(-Maths::ATan2(lookDir.x, lookDir.z));
			head.rotation.y -= body.rotation.y;

			head.rotation.x = Maths::Sin(lookDir.y) * 90;
		}

		// Left arm

		upperLeftArm.position = Vec3f(-0.25f, 0.75f, 0);
		upperLeftArm.rotation = Vec3f();
		upperLeftArm.rotation.x = (Maths::Pow(sin, 4) - 0.5f) * -50.0f;
		upperLeftArm.rotation.z = sin2 * 50;

		lowerLeftArm.position = Vec3f(-0.125f, -0.375f, -0.125f);
		lowerLeftArm.rotation = Vec3f();

		// Right arm

		upperRightArm.position = Vec3f(0.25f, 0.75f, 0);
		upperRightArm.rotation = Vec3f();
		upperRightArm.rotation.x = (Maths::Pow(sin, 4) - 0.5f) * -50.0f;
		upperRightArm.rotation.z = sin2 * 50;

		lowerRightArm.position = Vec3f(0.125f, -0.375f, -0.125f);
		lowerRightArm.rotation = Vec3f();

		// Left leg

		upperLeftLeg.position = Vec3f();
		upperLeftLeg.rotation = Vec3f();
		upperLeftLeg.rotation.z = 16 + (sin2 - 1) * 12;

		lowerLeftLeg.position = Vec3f(-0.125f, -0.375f, 0.125f);
		lowerLeftLeg.rotation = Vec3f();

		// Right leg

		upperRightLeg.position = Vec3f();
		upperRightLeg.rotation = Vec3f();
		upperRightLeg.rotation.z = -16 + (sin2 + 1) * 12;

		lowerRightLeg.position = Vec3f(0.125f, -0.375f, 0.125f);
		lowerRightLeg.rotation = Vec3f();
	}
}
