#include "IAnimation.as"
#include "HumanModel.as"
#include "Camera.as"

shared class DollLookAnim : IAnimation
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

	DollLookAnim(HumanModel@ model, Doll@ doll)
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
		// Body

		body.position = Vec3f(0, 0.75f, 0);
		body.rotation = Vec3f();

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

		lowerLeftArm.position = Vec3f(-0.125f, -0.375f, -0.125f);
		lowerLeftArm.rotation = Vec3f();

		// Right arm

		upperRightArm.position = Vec3f(0.25f, 0.75f, 0);
		upperRightArm.rotation = Vec3f();

		lowerRightArm.position = Vec3f(0.125f, -0.375f, -0.125f);
		lowerRightArm.rotation = Vec3f();

		// Left leg

		upperLeftLeg.position = Vec3f();
		upperLeftLeg.rotation = Vec3f();

		lowerLeftLeg.position = Vec3f(-0.125f, -0.375f, 0.125f);
		lowerLeftLeg.rotation = Vec3f();

		// Right leg

		upperRightLeg.position = Vec3f();
		upperRightLeg.rotation = Vec3f();

		lowerRightLeg.position = Vec3f(0.125f, -0.375f, 0.125f);
		lowerRightLeg.rotation = Vec3f();
	}
}
