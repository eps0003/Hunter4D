#include "MapBuilder.as"

shared class RedLightGreenLightMap : MapGenerator
{
	uint lineDist = 10;

	RedLightGreenLightMap(Vec3f dimensions)
	{
		super(dimensions);
	}

	void Load()
	{
		for (uint x = 0; x < map.dimensions.x; x++)
		for (uint z = 0; z < map.dimensions.z; z++)
		{
			SColor color;
			if (z == lineDist - 1 || z == map.dimensions.z - lineDist)
			{
				color = SColor(255, 255, 255, 255);
			}
			else
			{
				color = (x + z) % 2 == 0 ? SColor(255, 100, 100, 100) : SColor(255, 150, 150, 150);
			}

			map.SetBlock(x, 0, z, color);
		}
	}

	Vec3f getDollSpawnPos()
	{
		return Vec3f(map.dimensions.x * 0.5f, 1, map.dimensions.z - lineDist + 0.5f);
	}
}
