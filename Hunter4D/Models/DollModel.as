#include "Model.as"
#include "DollLookAnim.as"

shared class DollModel : HumanModel
{
	Doll@ doll;

	DollModel(Doll@ doll, float scale = 1.0f)
	{
		super("Doll.png", scale);
		@this.doll = doll;

		animator.AddAnimation("look", DollLookAnim(this, doll));
		animator.SetAnimation("look");
	}

	void PreRender()
	{
		Model::PreRender();
		Matrix::SetTranslation(matrix, doll.interPosition.x, doll.interPosition.y, doll.interPosition.z);
	}
}
