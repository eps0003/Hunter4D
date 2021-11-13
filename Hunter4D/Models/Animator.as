#include "IAnimation.as"
#include "Interpolation.as"

shared class Animator
{
	private Model@ model;
	private dictionary animations;

	private IAnimation@ animation;
	private string animName;

	uint animStartTime = 0;
	private uint animTransitionDuration = 3;

	Animator(Model@ model)
	{
		@this.model = model;
	}

	void AddAnimation(string name, IAnimation@ animation)
	{
		animations.set(name, @animation);
	}

	IAnimation@ getAnimation(string name)
	{
		IAnimation@ animation;
		animations.get(name, @animation);
		return animation;
	}

	void SetAnimation(string name)
	{
		IAnimation@ animation = getAnimation(name);
		if (animation !is null)
		{
			if (animation !is this.animation)
			{
				@this.animation = animation;
				animStartTime = getGameTime();

				ModelSegment@[] segments = model.getSegments();
				for (uint i = 0; i < segments.size(); i++)
				{
					ModelSegment@ segment = segments[i];
					segment.oldPosition = segment.interPosition;
					segment.oldRotation = segment.interRotation;
				}
			}
		}
		else if (name != animName)
		{
			warn("Unable to set nonexistent animation: " + name);
		}

		animName = name;
	}

	float getTransitionTime()
	{
		float deltaTime = Interpolation::getGameTime() - animStartTime;
		return Maths::Clamp01(deltaTime / animTransitionDuration);
	}

	void Update()
	{
		if (animation !is null)
		{
			animation.Update();
		}
	}
}