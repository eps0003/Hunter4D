#include "CameraCommon.as"
#include "Vec3f.as"
#include "Interpolation.as"

class Camera
{
	Vec3f position;
	Vec3f oldPosition;
	private Vec3f _interPosition;
	Vec3f rotation;
	Vec3f oldRotation;
	private Vec3f _interRotation;

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

	void Update()
	{
		oldPosition = position;
		oldRotation = rotation;
	}

	void Render()
	{
		Interpolate();
		Render::SetTransform(modelMatrix, viewMatrix, projectionMatrix);
	}

	private void Interpolate()
	{
		float t = Interpolation::getFrameTime();
		interPosition = oldPosition.lerp(position, t);
		interRotation = oldRotation.lerp(rotation, t);
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
		Matrix::SetTranslation(translation, -interPosition.x, -interPosition.y, -interPosition.z);

		float[] thirdPerson;
		Matrix::MakeIdentity(thirdPerson);
		Matrix::SetTranslation(thirdPerson, 0, 0, 10);

		Matrix::Multiply(rotationMatrix, translation, viewMatrix);
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

		Matrix::Multiply(tempX, tempZ, rotationMatrix);
		Matrix::Multiply(rotationMatrix, tempY, rotationMatrix);
	}
}
