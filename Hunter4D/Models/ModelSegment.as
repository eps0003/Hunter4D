shared class ModelSegment
{
	private SMesh mesh;
	private ModelSegment@[] children;
	float[] matrix;

	Vec3f position;
	Vec3f oldPosition;
	Vec3f interPosition;

	Vec3f rotation;
	Vec3f oldRotation;
	Vec3f interRotation;

	float scale = 1.0f;

	ModelSegment(string modelPath, string texture)
	{
		mesh.LoadObjIntoMesh(modelPath);

		SMaterial material;
		material.AddTexture(texture);
		material.SetFlag(SMaterial::LIGHTING, false);
		material.SetFlag(SMaterial::BILINEAR_FILTER, false);
		material.SetFlag(SMaterial::BACK_FACE_CULLING, false);
		material.SetFlag(SMaterial::FOG_ENABLE, true);
		material.SetMaterialType(SMaterial::TRANSPARENT_ALPHA_CHANNEL_REF);
		mesh.SetMaterial(material);
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
		interPosition = oldPosition.lerp(position, t);
		interRotation = oldRotation.lerpAngle(rotation, t);
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

	private void Transform(float[]@ matrix)
	{
		Matrix::MakeIdentity(this.matrix);

		Matrix::SetTranslation(this.matrix, interPosition.x, interPosition.y, interPosition.z);
		Matrix::SetRotationDegrees(this.matrix, -interRotation.x, -interRotation.y, -interRotation.z);

		float[] scaleMatrix;
		Matrix::MakeIdentity(scaleMatrix);
		Matrix::SetScale(scaleMatrix, scale, scale, scale);

		Matrix::MultiplyImmediate(this.matrix, scaleMatrix);
		Matrix::MultiplyImmediate(matrix, this.matrix);
		Render::SetModelTransform(matrix);

		this.matrix = matrix;
	}
}
