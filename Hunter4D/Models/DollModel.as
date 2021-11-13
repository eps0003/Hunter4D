#include "Model.as"
#include "DollLookAnim.as"

shared class DollModel : HumanModel
{
	Doll@ doll;

	DollModel(Doll@ doll)
	{
		super("Doll.png", 2.0f);
		@this.doll = doll;

		animator.AddAnimation("look", DollLookAnim(this));
		animator.SetAnimation("look");
	}

	void PreRender()
	{
		Model::PreRender();
		Matrix::SetTranslation(matrix, doll.interPosition.x, doll.interPosition.y, doll.interPosition.z);
	}
}
