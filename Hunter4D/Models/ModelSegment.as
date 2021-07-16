class ModelSegment
{
	private SMesh mesh;
	private ModelSegment@[] children;
	private float[] matrix;

	Vec3f position;
	Vec3f oldPosition;
	Vec3f interPosition;

	Vec3f rotation;
	Vec3f oldRotation;
	Vec3f interRotation;

	ModelSegment(string modelPath)
	{
		mesh.LoadObjIntoMesh(modelPath);
		Matrix::MakeIdentity(matrix);
	}

	void Render(float[] matrix, float t)
	{
		Interpolate(t);
		Transform(matrix);

		mesh.RenderMeshWithMaterial();

		for (uint i = 0; i < children.size(); i++)
		{
			children[i].Render(matrix, t);
		}
	}

	void AddChild(ModelSegment@ segment)
	{
		children.push_back(segment);
	}

	void SetParent(ModelSegment@ segment)
	{
		segment.children.push_back(this);
	}

	ModelSegment@[] getChildren()
	{
		return children;
	}

	SMesh@ getMesh()
	{
		return mesh;
	}

	private void Interpolate(float t)
	{
		interPosition = oldPosition.lerp(this.position, t);
		interRotation = oldRotation.lerpAngle(this.rotation, t);
	}

	private void Transform(float[]@ matrix)
	{
		Matrix::SetTranslation(this.matrix, interPosition.x, interPosition.y, interPosition.z);
		Matrix::SetRotationDegrees(this.matrix, -interRotation.x, -interRotation.y, -interRotation.z);

		Matrix::MultiplyImmediate(matrix, this.matrix);
		Render::SetModelTransform(matrix);
	}
}