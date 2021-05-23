class AABB : IBounds
{
	Vec3f min;
	Vec3f max;
	Vec3f dim;

	AABB(Vec3f min, Vec3f max)
	{
		this.min = min;
		this.max = max;
		this.dim = (max - min).abs();
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
		Vec3f dim = Map::getMap().dimensions;
		return (
			worldPos.x + min.x < 0 ||
			worldPos.x + max.x > dim.x ||
			worldPos.z + min.z < 0 ||
			worldPos.z + max.z > dim.z
		);
	}

	Vec3f getRandomPoint()
	{
		Random random();
		return Vec3f(
			min.x + random.Next() * dim.x,
			min.y + random.Next() * dim.y,
			min.z + random.Next() * dim.z
		);
	}

	bool intersectsNewSolid(Vec3f currentPos, Vec3f worldPos)
	{
		Map@ map = Map::getMap();

		for (int x = worldPos.x + min.x; x < worldPos.x + max.x; x++)
		for (int y = worldPos.y + min.y; y < worldPos.y + max.y; y++)
		for (int z = worldPos.z + min.z; z < worldPos.z + max.z; z++)
		{
			Vec3f floor = (currentPos + min).floor();
			Vec3f ceil = (currentPos + max).ceil();

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

			u8 block = map.getBlockSafe(x, y, z);
			Block@ blockType = Block::getBlock(block);
			if (blockType.solid)
			{
				return true;
			}
		}

		return false;
	}
}
