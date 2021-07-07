#include "CameraCommon.as"
#include "Vec3f.as"
#include "Interpolation.as"

class Camera
{
	Vec3f position;
	private Vec3f _oldPosition;
	private Vec3f _interPosition;

	Vec3f rotation;
	private Vec3f _oldRotation;
	private Vec3f _interRotation;

	private float _fov = 70.0f;
	private float _renderDistance = 150.0f;

	private float[] _modelMatrix;
	private float[] _viewMatrix;
	private float[] _projectionMatrix;
	private float[] _rotationMatrix;

	Camera()
	{
		Matrix::MakeIdentity(_modelMatrix);
		Matrix::MakeIdentity(_viewMatrix);
		Matrix::MakeIdentity(_projectionMatrix);
		Matrix::MakeIdentity(_rotationMatrix);

		UpdateViewMatrix();
		UpdateRotationMatrix();
		UpdateProjectionMatrix();

		Render::SetFog(SColor(255, 165, 189, 200), SMesh::LINEAR, renderDistance - 10, renderDistance, 0, false, true);
	}

	void Update()
	{
		_oldPosition = position;
		_oldRotation = rotation;
	}

	void Render()
	{
		Render::SetTransform(_modelMatrix, _viewMatrix, _projectionMatrix);
	}

	void Interpolate()
	{
		float t = Interpolation::getFrameTime();
		interPosition = _oldPosition.lerp(position, t);
		interRotation = _oldRotation.lerp(rotation, t);
	}

	Vec3f interPosition
	{
		get const
		{
			return _interPosition;
		}
		set
		{
			_interPosition = value;
			UpdateViewMatrix();
		}
	}

	Vec3f interRotation
	{
		get const
		{
			return _interRotation;
		}
		set
		{
			_interRotation = value;
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

	float[] getModelMatrix()
	{
		return _modelMatrix;
	}

	float[] getViewMatrix()
	{
		return _viewMatrix;
	}

	float[] getProjectionMatrix()
	{
		return _projectionMatrix;
	}

	float[] getRotationMatrix()
	{
		return _rotationMatrix;
	}

	private void UpdateProjectionMatrix()
	{
		float ratio = getScreenWidth() / float(getScreenHeight());

		Matrix::MakePerspective(_projectionMatrix,
			fov * Maths::Pi / 180.0f,
			ratio,
			0.01f, renderDistance
		);
	}

	private void UpdateViewMatrix()
	{
		float[] translation;
		Matrix::MakeIdentity(translation);
		Matrix::SetTranslation(translation, -interPosition.x, -interPosition.y, -interPosition.z);

		// float[] thirdPerson;
		// Matrix::MakeIdentity(thirdPerson);
		// Matrix::SetTranslation(thirdPerson, 0, 0, 10);

		Matrix::Multiply(_rotationMatrix, translation, _viewMatrix);
		// Matrix::Multiply(thirdPerson, _viewMatrix, _viewMatrix);
	}

	private void UpdateRotationMatrix()
	{
		float[] tempX;
		Matrix::MakeIdentity(tempX);
		Matrix::SetRotationDegrees(tempX, interRotation.x, 0, 0);

		float[] tempY;
		Matrix::MakeIdentity(tempY);
		Matrix::SetRotationDegrees(tempY, 0, interRotation.y, 0);

		float[] tempZ;
		Matrix::MakeIdentity(tempZ);
		Matrix::SetRotationDegrees(tempZ, 0, 0, interRotation.z);

		Matrix::Multiply(tempX, tempZ, _rotationMatrix);
		Matrix::Multiply(_rotationMatrix, tempY, _rotationMatrix);
	}
}
