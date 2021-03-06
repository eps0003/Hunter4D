#include "IBounds.as"
#include "Map.as"

shared class AABB : IBounds
{
	Vec3f min;
	Vec3f max;
	Vec3f dim;
	Vec3f center;
	float radius; // Radius of a sphere that this box inscribes

	private Random random(Time());
	private Map@ map = Map::getMap();

	AABB(Vec3f min, Vec3f max)
	{
		this.min = min;
		this.max = max;
		UpdateProperties();
	}

	private void UpdateProperties()
	{
		dim = (max - min).abs();
		center = (max + min) * 0.5f;
		radius = dim.mag() * 0.5f;
	}

	bool intersectsAABB(Vec3f thisPos, AABB other, Vec3f otherPos)
	{
		for (uint i = 0; i < 3; i++)
		{
			if (thisPos[i] + min[i] >= otherPos[i] + other.max[i] || thisPos[i] + max[i] <= otherPos[i] + other.min[i])
			{
				return false;
			}
		}
		return true;
	}

	bool intersectsPoint(Vec3f worldPos, Vec3f point)
	{
		return (
			point.x > worldPos.x + min.x &&
			point.x < worldPos.x + max.x &&
			point.y > worldPos.y + min.y &&
			point.y < worldPos.y + max.y &&
			point.z > worldPos.z + min.z &&
			point.z < worldPos.z + max.z
		);
	}

	bool intersectsMapEdge(Vec3f worldPos)
	{
		Vec3f dim = map.dimensions;
		return (
			worldPos.x + min.x < 0 ||
			worldPos.x + max.x > dim.x ||
			worldPos.z + min.z < 0 ||
			worldPos.z + max.z > dim.z
		);
	}

	Vec3f getRandomPoint()
	{
		return Vec3f(
			min.x + random.NextFloat() * dim.x,
			min.y + random.NextFloat() * dim.y,
			min.z + random.NextFloat() * dim.z
		);
	}

	bool intersectsNewSolid(Vec3f currentPos, Vec3f worldPos)
	{
		Map@ map = Map::getMap();

		Vec3f floor = (currentPos + min).floor();
		Vec3f ceil = (currentPos + max).ceil();

		Vec3f min2 = Vec3f().max(worldPos + min);
		Vec3f max2 = map.dimensions.min(worldPos + max);

		for (int y = min2.y; y < max2.y; y++)
		for (int x = min2.x; x < max2.x; x++)
		for (int z = min2.z; z < max2.z; z++)
		{
			// Ignore voxels the actor is currently intersecting
			if (x >= floor.x && x < ceil.x &&
				y >= floor.y && y < ceil.y &&
				z >= floor.z && z < ceil.z)
			{
				continue;
			}

			if (map.isSolid(map.getBlock(x, y, z)))
			{
				return true;
			}
		}

		return false;
	}

	bool intersectsVoxel(Vec3f worldPos, Vec3f voxelWorldPos)
	{
		for (int x = worldPos.x + min.x; x < worldPos.x + max.x; x++)
		for (int y = worldPos.y + min.y; y < worldPos.y + max.y; y++)
		for (int z = worldPos.z + min.z; z < worldPos.z + max.z; z++)
		{
			if (Vec3f(x, y, z) == voxelWorldPos)
			{
				return true;
			}
		}
		return false;
	}

	AABB@ getBounds()
	{
		return this;
	}

	void Serialize(CBitStream@ bs)
	{
		min.Serialize(bs);
		max.Serialize(bs);
	}

	bool deserialize(CBitStream@ bs)
	{
		bool success = min.deserialize(bs) && max.deserialize(bs);
		if (success) UpdateProperties();
		return success;
	}
}
