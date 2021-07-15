class ModelSegment
{
	SMesh mesh;

	ModelSegment@ parent;
	ModelSegment@[] children;

	private Vec3f _position;
	private Vec3f _rotation;
	private bool transform = true;

	private float[] matrix;

	ModelSegment(string modelPath)
	{
		mesh.LoadObjIntoMesh(modelPath);
		Matrix::MakeIdentity(matrix);
	}

	void Render(float[] matrix)
	{
		Transform(matrix);
		mesh.RenderMeshWithMaterial();

		for (uint i = 0; i < children.size(); i++)
		{
			children[i].Render(matrix);
		}
	}

	void AddChild(ModelSegment@ segment)
	{
		children.push_back(segment);
		@segment.parent = segment;
	}

	void AddParent(ModelSegment@ segment)
	{
		@parent = segment;
		segment.children.push_back(segment);
	}

	private void Transform(float[]@ matrix)
	{
		if (transform)
		{
			transform = false;

			Matrix::SetTranslation(this.matrix, position.x, position.y, position.z);
			Matrix::SetRotationDegrees(this.matrix, -rotation.x, -rotation.y, -rotation.z);

			Matrix::MultiplyImmediate(matrix, this.matrix);
			Render::SetModelTransform(matrix);
		}
	}

	Vec3f position
	{
		get const
		{
			return _position;
		}
		set
		{
			_position = value;
			transform = true;
		}
	}

	Vec3f rotation
	{
		get const
		{
			return _rotation;
		}
		set
		{
			_rotation = value;
			transform = true;
		}
	}
}