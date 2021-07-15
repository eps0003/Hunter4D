#include "CameraCommon.as"
#include "Vec3f.as"
#include "Interpolation.as"

class Camera
{
	Vec3f position;
	private Vec3f oldPosition;
	private Vec3f _interPosition;

	Vec3f rotation;
	private Vec3f oldRotation;
	private Vec3f _interRotation;

	private float fov = 70.0f;
	private float renderDistance = 150.0f;
	private SColor fogColor = SColor(255, 165, 189, 200);

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

		Render::SetFog(fogColor, SMesh::LINEAR, renderDistance - 10, renderDistance, 0, false, true);
	}

	void Update()
	{
		oldPosition = position;
		oldRotation = rotation;
	}

	void Render()
	{
		Vec2f screenDim = getDriver().getScreenDimensions();
		GUI::DrawRectangle(Vec2f_zero, screenDim, fogColor);

		Render::SetTransform(modelMatrix, viewMatrix, projectionMatrix);
	}

	void Interpolate()
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

	float getFOV()
	{
		return fov;
	}

	void SetFOV(float fov)
	{
		this.fov = fov;
		UpdateProjectionMatrix();
	}

	float getRenderDistance()
	{
		return renderDistance;
	}

	void SetRenderDistance(float distance)
	{
		renderDistance = distance;
		UpdateProjectionMatrix();
	}

	float[] getModelMatrix()
	{
		return modelMatrix;
	}

	float[] getViewMatrix()
	{
		return viewMatrix;
	}

	float[] getProjectionMatrix()
	{
		return projectionMatrix;
	}

	float[] getRotationMatrix()
	{
		return rotationMatrix;
	}

	private void UpdateProjectionMatrix()
	{
		float ratio = getScreenWidth() / float(getScreenHeight());

		Matrix::MakePerspective(projectionMatrix,
			Maths::toRadians(fov),
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
		Matrix::SetTranslation(thirdPerson, 0, 0, 4);

		Matrix::Multiply(rotationMatrix, translation, viewMatrix);
		Matrix::Multiply(thirdPerson, viewMatrix, viewMatrix);
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
