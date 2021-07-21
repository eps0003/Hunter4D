#include "IBounds.as"
#include "Map.as"

shared class AABB : IBounds
{
	Vec3f min;
	Vec3f max;
	Vec3f dim;
	Vec3f center;
	float radius; // Radius of a sphere that this box inscribes

	private Random random(getGameTime());
	private Map@ map = Map::getMap();

	AABB(Vec3f min, Vec3f max)
	{
		this.min = min;
		this.max = max;

		dim = (max - min).abs();
		center = dim / 2.0f + min;
		radius = Maths::Sqrt(dim.x*dim.x + dim.y*dim.y + dim.z*dim.z) * 0.5f;
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

		for (int x = worldPos.x + min.x; x < worldPos.x + max.x; x++)
		for (int y = worldPos.y + min.y; y < worldPos.y + max.y; y++)
		for (int z = worldPos.z + min.z; z < worldPos.z + max.z; z++)
		{
			bool alreadyIntersecting = (
				x >= floor.x && x < ceil.x &&
				y >= floor.y && y < ceil.y &&
				z >= floor.z && z < ceil.z
			);

			// Ignore voxels the actor is currently intersecting
			if (alreadyIntersecting)
			{
				continue;
			}

			SColor block = map.getBlockSafe(x, y, z);
			if (Blocks::isSolid(block))
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

	void Serialize(CBitStream@ bs)
	{
		min.Serialize(bs);
		max.Serialize(bs);
	}

	bool deserialize(CBitStream@ bs)
	{
		return min.deserialize(bs) && max.deserialize(bs);
	}
}
