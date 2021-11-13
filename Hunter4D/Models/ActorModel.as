#include "HumanModel.as"
#include "Camera.as"
#include "Skins.as"

shared class ActorModel : HumanModel
{
	Actor@ actor;

	ActorModel(Actor@ actor)
	{
		super(Skins::getSkinName(actor.getPlayer()), 0.9f * actor.getScale());
		@this.actor = actor;

		animator.AddAnimation("idle", ActorIdleAnim(this));
		animator.AddAnimation("run", ActorRunAnim(this));
		animator.AddAnimation("jump", ActorJumpAnim(this));
		// animator.AddAnimation("taunt", ActorJumpingJacksAnim(this));

		animator.SetAnimation("idle");
	}

	void PreRender()
	{
		Model::PreRender();
		Matrix::SetTranslation(matrix, actor.interPosition.x, actor.interPosition.y, actor.interPosition.z);
	}
}
