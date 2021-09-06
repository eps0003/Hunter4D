#include "IAnimation.as"

shared class Model
{
	private float scale = 1.0f;

	private float[] matrix;

	private ModelSegment@[] segments;

	private dictionary animations;
	private IAnimation@ animation;
	private string animName;
	uint animStartTime = 0;
	private uint animTransitionDuration = 3;

	Model(float scale)
	{
		this.scale = scale;
	}

	void AddSegment(ModelSegment@ segment)
	{
		segments.push_back(segment);
	}

	void AddAnimation(string name, IAnimation@ animation)
	{
		animations.set(name, @animation);
	}

	void SetAnimation(string name)
	{
		IAnimation@ animation;
		if (animations.get(name, @animation))
		{
			if (animation !is this.animation)
			{
				@this.animation = animation;

				animStartTime = getGameTime();

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

	void Update()
	{
		Matrix::MakeIdentity(matrix);
		Matrix::SetScale(matrix, scale, scale, scale);

		if (animation !is null)
		{
			animation.Update();
		}
	}

	void Render()
	{
		Update();

		float t = animStartTime > 0 ? Maths::Clamp01((Interpolation::getGameTime() - animStartTime) / float(animTransitionDuration)) : 1.0f;
		segments[0].Render(matrix, t);
	}
}