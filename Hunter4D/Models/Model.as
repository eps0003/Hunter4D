#include "IAnimation.as"

class Model
{
	private float[] matrix;
	private SMaterial material;

	private ModelSegment@[] segments;

	private IAnimation@ animation;
	private uint animStartTime = 0;
	private uint animTransitionDuration = 3;

	Model(string texture, float scale)
	{
		Matrix::MakeIdentity(matrix);
		Matrix::SetScale(matrix, scale, scale, scale);

		material.AddTexture(texture);
		material.SetFlag(SMaterial::LIGHTING, false);
		material.SetFlag(SMaterial::BILINEAR_FILTER, false);
		material.SetFlag(SMaterial::BACK_FACE_CULLING, false);
		material.SetFlag(SMaterial::FOG_ENABLE, true);
	}

	void AddSegment(ModelSegment@ segment)
	{
		segments.push_back(segment);
		segment.getMesh().SetMaterial(material);
	}

	void SetAnimation(IAnimation@ animation)
	{
		if (animation !is this.animation)
		{
			@this.animation = animation;

			if (this.animation !is null)
			{
				animStartTime = getGameTime();
			}

			for (uint i = 0; i < segments.size(); i++)
			{
				ModelSegment@ segment = segments[i];
				segment.oldPosition = segment.interPosition;
				segment.oldRotation = segment.interRotation;
			}
		}
	}

	void Update()
	{
		animation.Update();
	}

	void Render()
	{
		Update();

		float t = animStartTime > 0 ? Maths::Clamp01((Interpolation::getGameTime() - animStartTime) / float(animTransitionDuration)) : 1.0f;
		segments[0].Render(matrix, t);
	}
}