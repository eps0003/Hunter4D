#include "CameraCommon.as"
#include "Vec3f.as"

class Camera
{
	private Vec3f _position;
	private Vec3f _rotation;

	private float _fov = 70.0f;
	private float _renderDistance = 70.0f;

	private float[] modelMatrix;
	private float[] viewMatrix;
	private float[] projectionMatrix;
	private float[] rotationMatrix;

	Camera()
	{
		Matrix::MakeIdentity(modelMatrix);
		Matrix::MakeIdentity(viewMatrix);
		Matrix::MakeIdentity(projectionMatrix);
		Matrix::MakeIdentity(rotationMatrix);

		UpdateViewMatrix();
		UpdateRotationMatrix();
		UpdateProjectionMatrix();

		// Render::SetFog(getSkyColor(), SMesh::LINEAR, renderDistance - 10, renderDistance, 0, false, true);
	}

	void Render()
	{
		Render::SetTransform(modelMatrix, viewMatrix, projectionMatrix);
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
			UpdateViewMatrix();
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
			UpdateRotationMatrix();
		}
	}

	float fov
	{
		get const
		{
			return _fov;
		}
		set
		{
			_fov = value;
			UpdateProjectionMatrix();
		}
	}

	float renderDistance
	{
		get const
		{
			return _renderDistance;
		}
		set
		{
			_renderDistance = value;
			UpdateProjectionMatrix();
		}
	}

	private void UpdateProjectionMatrix()
	{
		Vec2f screenDim = getDriver().getScreenDimensions();
		float ratio = float(screenDim.x) / float(screenDim.y);

		Matrix::MakePerspective(projectionMatrix,
			fov * Maths::Pi / 180,
			ratio,
			0.01f, renderDistance
		);
	}

	private void UpdateViewMatrix()
	{
		float[] translation;
		Matrix::MakeIdentity(translation);
		Matrix::SetTranslation(translation, -position.x, -position.y, -position.z);

		float[] thirdPerson;
		Matrix::MakeIdentity(thirdPerson);
		Matrix::SetTranslation(thirdPerson, 0, 0, 10);

		Matrix::Multiply(rotationMatrix, translation, viewMatrix);
	}

	private void UpdateRotationMatrix()
	{
		float[] tempX;
		Matrix::MakeIdentity(tempX);
		Matrix::SetRotationDegrees(tempX, rotation.x, 0, 0);

		float[] tempY;
		Matrix::MakeIdentity(tempY);
		Matrix::SetRotationDegrees(tempY, 0, rotation.y, 0);

		float[] tempZ;
		Matrix::MakeIdentity(tempZ);
		Matrix::SetRotationDegrees(tempZ, 0, 0, rotation.z);

		Matrix::Multiply(tempX, tempZ, rotationMatrix);
		Matrix::Multiply(rotationMatrix, tempY, rotationMatrix);
	}
}
