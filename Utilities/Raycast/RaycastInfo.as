class RaycastInfo
{
	Ray ray;
	float distance = 0;
	Vec3f normal;
	Vec3f hitPos;
	Vec3f hitWorldPos;

	RaycastInfo() {}

	RaycastInfo(Ray ray, Vec3f hitWorldPos, float distance, Vec3f normal)
	{
		this.hitWorldPos = hitWorldPos;
		this.ray = ray;
		this.distance = distance;
		this.normal = normal;
		this.hitPos = ray.position + (ray.direction * distance);
	}
}
