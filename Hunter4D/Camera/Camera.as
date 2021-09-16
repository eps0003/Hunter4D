#include "CameraCommon.as"
#include "Vec3f.as"
#include "Interpolation.as"
#include "Config.as"
#include "Frustum.as"
#include "Ray.as"

shared enum CameraType
{
	FirstPerson,
	ThirdPersonBehind,
	ThirdPersonInFront,
	Count
}

shared class Camera
{
	Vec3f position;
	private Vec3f oldPosition;
	private Vec3f _interPosition;

	Vec3f rotation;
	private Vec3f oldRotation;
	private Vec3f _interRotation;

	private float fov;
	private float renderDistance;
	private SColor fogColor = SColor(255, 165, 189, 200);

	private u16 cameraType = CameraType::ThirdPersonBehind;
	private float thirdPersonDistance = 4.0f;

	private float[] modelMatrix;
	private float[] viewMatrix;
	private float[] projectionMatrix;
	private float[] rotationMatrix;

	private Frustum frustum;

	private Driver@ driver;

	Camera()
	{
		@driver = getDriver();

		Matrix::MakeIdentity(modelMatrix);
		Matrix::MakeIdentity(viewMatrix);
		Matrix::MakeIdentity(projectionMatrix);
		Matrix::MakeIdentity(rotationMatrix);

		ConfigFile@ cfg = Config::getConfig();
		fov = cfg.read_f32("fov");
		renderDistance = cfg.read_f32("render_distance");

		UpdateViewMatrix();
		UpdateRotationMatrix();
		UpdateProjectionMatrix();
		UpdateFog();
		UpdateFrustum();
	}

	void Update()
	{
		oldPosition = position;
		oldRotation = rotation;
	}

	void Render()
	{
		Vec2f screenDim = driver.getScreenDimensions();
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
			UpdateFrustum();
		}
	}

	float getFOV()
	{
		return fov;
	}

	void SetFOV(float fov)
	{
		if (this.fov == fov) return;

		this.fov = fov;
		UpdateProjectionMatrix();
		UpdateFrustum();

		ConfigFile@ cfg = Config::getConfig();
		cfg.add_f32("fov", fov);
		Config::SaveConfig(cfg);
	}

	float getRenderDistance()
	{
		return renderDistance;
	}

	void SetRenderDistance(float distance)
	{
		if (renderDistance == distance) return;

		renderDistance = distance;
		UpdateProjectionMatrix();
		UpdateFog();
		UpdateFrustum();

		ConfigFile@ cfg = Config::getConfig();
		cfg.add_f32("render_distance", distance);
		Config::SaveConfig(cfg);
	}

	Frustum@ getFrustum()
	{
		return frustum;
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

	u16 getCameraType()
	{
		return cameraType;
	}

	void NextCameraType()
	{
		cameraType = (cameraType + 1) % CameraType::Count;
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

		Matrix::Multiply(rotationMatrix, translation, viewMatrix);

		if (cameraType == CameraType::ThirdPersonBehind || cameraType == CameraType::ThirdPersonInFront)
		{
			float dist = thirdPersonDistance;
			float padding = 0.05f;

			Vec3f dir = cameraType == CameraType::ThirdPersonBehind ? -interRotation.dir() : interRotation.dir();
			Ray ray(interPosition, dir);

			RaycastInfo raycast;
			if (ray.raycastBlock(dist + 1, true, raycast))
			{
				float dot = raycast.normal.dot(ray.direction);
				float angle = Maths::Pi * 0.5f * (1 + dot);
				float len = padding / Maths::Cos(angle);
				dist = Maths::Min(raycast.distance - len, thirdPersonDistance);
			}

			float[] thirdPerson;
			Matrix::MakeIdentity(thirdPerson);
			Matrix::SetTranslation(thirdPerson, 0, 0, dist);

			if (cameraType == CameraType::ThirdPersonInFront)
			{
				Matrix::SetRotationDegrees(thirdPerson, 0, 180, 0);
			}

			Matrix::Multiply(thirdPerson, viewMatrix, viewMatrix);
		}
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

	private void UpdateFog()
	{
		Render::SetFog(fogColor, SMesh::LINEAR, renderDistance - 10, renderDistance, 0, false, true);
	}

	private void UpdateFrustum()
	{
		float[] rotProjMatrix;
		Matrix::Multiply(projectionMatrix, rotationMatrix, rotProjMatrix);
		frustum.Update(rotProjMatrix);
	}
}
