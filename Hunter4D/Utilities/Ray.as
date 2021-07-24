#include "Vec3f.as"
#include "Map.as"

shared class Ray
{
	Vec3f position;
	Vec3f direction;

	Ray(Vec3f position, Vec3f direction)
	{
		this.position = position;
		this.direction = direction.normalized();
	}

	// https://theshoemaker.de/2016/02/ray-casting-in-2d-grids/
	bool raycastBlock(float distance, bool solidOnly, RaycastInfo &out raycastInfo)
	{
		Map@ map = Map::getMap();

		Vec3f worldPos = position.floor();

		Vec3f deltaDist(
			direction.x == 0 ? 0.0f : Maths::Abs(1.0f / direction.x),
			direction.y == 0 ? 0.0f : Maths::Abs(1.0f / direction.y),
			direction.z == 0 ? 0.0f : Maths::Abs(1.0f / direction.z)
		);

		Vec3f sideDist;
		Vec3f step;
		float dist = 0;
		Vec3f normal;

		if (direction.x < 0)
		{
			step.x = -1;
			sideDist.x = (position.x - worldPos.x) * deltaDist.x;
		}
		else
		{
			step.x = 1;
			sideDist.x = (worldPos.x + 1.0f - position.x) * deltaDist.x;
		}

		if (direction.y < 0)
		{
			step.y = -1;
			sideDist.y = (position.y - worldPos.y) * deltaDist.y;
		}
		else
		{
			step.y = 1;
			sideDist.y = (worldPos.y + 1.0f - position.y) * deltaDist.y;
		}

		if (direction.z < 0)
		{
			step.z = -1;
			sideDist.z = (position.z - worldPos.z) * deltaDist.z;
		}
		else
		{
			step.z = 1;
			sideDist.z = (worldPos.z + 1.0f - position.z) * deltaDist.z;
		}

		while (distance > 0 && dist < distance)
		{
			SColor block = map.getBlockSafe(worldPos);

			//hit a block
			bool hit = solidOnly ? map.isSolid(block) : map.isVisible(block);
			if (hit)
			{
				dist = Maths::Max(0, dist);
				raycastInfo = RaycastInfo(this, worldPos, dist, normal);
				return true;
			}

			if (deltaDist.x != 0 && sideDist.x < sideDist.y)
			{
				if (deltaDist.z != 0 && sideDist.z < sideDist.x)
				{
					dist = sideDist.z;
					sideDist.z += deltaDist.z;
					worldPos.z += step.z;
					normal = Vec3f(0.0f, 0.0f, -step.z);
				}
				else
				{
					dist = sideDist.x;
					sideDist.x += deltaDist.x;
					worldPos.x += step.x;
					normal = Vec3f(-step.x, 0.0f, 0.0f);
				}
			}
			else
			{
				if (deltaDist.y != 0 && sideDist.y < sideDist.z)
				{
					dist = sideDist.y;
					sideDist.y += deltaDist.y;
					worldPos.y += step.y;
					normal = Vec3f(0.0f, -step.y, 0.0f);
				}
				else
				{
					dist = sideDist.z;
					sideDist.z += deltaDist.z;
					worldPos.z += step.z;
					normal = Vec3f(0.0f, 0.0f, -step.z);
				}
			}
		}

		return false;
	}

	bool intersectsAABB(AABB@ aabb, Vec3f aabbPosition, float &out distance)
	{
		Vec3f aabbMin = aabbPosition + aabb.min;
		Vec3f aabbMax = aabbPosition + aabb.max;

		float tMinX = direction.x != 0 ? (aabbMin.x - position.x) / direction.x : 0;
		float tMaxX = direction.x != 0 ? (aabbMax.x - position.x) / direction.x : 1;
		if (tMaxX < tMinX)
		{
			float temp = tMaxX;
			tMaxX = tMinX;
			tMinX = temp;
		}

		float tMinY = direction.y != 0 ? (aabbMin.y - position.y) / direction.y : 0;
		float tMaxY = direction.y != 0 ? (aabbMax.y - position.y) / direction.y : 1;
		if (tMaxY < tMinY)
		{
			float temp = tMaxY;
			tMaxY = tMinY;
			tMinY = temp;
		}

		float tMinZ = direction.z != 0 ? (aabbMin.z - position.z) / direction.z : 0;
		float tMaxZ = direction.z != 0 ? (aabbMax.z - position.z) / direction.z : 1;
		if (tMaxZ < tMinZ)
		{
			float temp = tMaxZ;
			tMaxZ = tMinZ;
			tMinZ = temp;
		}

		float tMin = (tMinX > tMinZ) ? tMinX : tMinZ;
		float tMax = (tMaxX < tMaxZ) ? tMaxX : tMaxZ;

		if (tMinX > tMaxY || tMinY > tMaxX) return false;
		if (tMin > tMaxZ || tMinZ > tMax) return false;
		if (tMinZ > tMin) tMin = tMinZ;
		if (tMaxZ < tMax) tMax = tMaxZ;

		// https://youtu.be/4h-jlOBsndU?t=1740
		distance = Maths::Max(0, tMin);

		return true;
	}
}

shared class RaycastInfo
{
	Ray ray;
	float distance = 0;
	Vec3f normal;
	Vec3f hitPos;
	Vec3f hitWorldPos;

	RaycastInfo(Ray ray, Vec3f hitWorldPos, float distance, Vec3f normal)
	{
		this.hitWorldPos = hitWorldPos;
		this.ray = ray;
		this.distance = distance;
		this.normal = normal;
		this.hitPos = ray.position + (ray.direction * distance);
	}
}
