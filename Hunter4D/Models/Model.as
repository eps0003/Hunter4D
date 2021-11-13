#include "IAnimation.as"
#include "Animator.as"

shared class Model
{
	float scale = 1.0f;
	Animator@ animator;

	private float[] matrix;

	private dictionary segments;
	private ModelSegment@ rootSegment;

	Model(float scale)
	{
		this.scale = scale;
		@this.animator = Animator(this);
	}

	void AddSegment(ModelSegment@ segment)
	{
		string uniqueName = "_segment" + segments.getSize();
		AddSegment(uniqueName, segment);
	}

	void AddSegment(string name, ModelSegment@ segment)
	{
		if (segments.isEmpty())
		{
			@rootSegment = segment;
		}

		segments.set(name, @segment);
	}

	ModelSegment@ getSegment(string name)
	{
		ModelSegment@ segment;
		segments.get(name, @segment);
		return segment;
	}

	ModelSegment@[] getSegments()
	{
		ModelSegment@[] allSegments;

		string[] segmentKeys = segments.getKeys();
		for (uint i = 0; i < segmentKeys.size(); i++)
		{
			ModelSegment@ segment = getSegment(segmentKeys[i]);
			allSegments.push_back(segment);
		}

		return allSegments;
	}

	void PreRender()
	{
		Matrix::MakeIdentity(matrix);
	}

	void Render()
	{
		PreRender();

		animator.Update();

		float[] scaleMatrix;
		Matrix::MakeIdentity(scaleMatrix);
		Matrix::SetScale(scaleMatrix, scale, scale, scale);
		Matrix::MultiplyImmediate(matrix, scaleMatrix);

		rootSegment.Render(matrix, animator.getTransitionTime());
	}
}