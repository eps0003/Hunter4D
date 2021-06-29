#include "Loader.as"
#include "Map.as"

void onInit(CRules@ this)
{
    this.set_string("loading message", "Generating map...");
}

void onTick(CRules@ this)
{
	if (isServer())
	{
		Map@ map = Map::getMap();
		map = Map(Vec3f(32, 8, 32));

		for (uint x = 0; x < map.dimensions.x; x++)
		for (uint z = 0; z < map.dimensions.z; z++)
		{
			map.SetBlock(x, 0, z, 1);
		}

		Map::getMapSyncer().AddRequestForEveryone();
	}

    print("Map generated!");
    Loader::getLoader().NextStage();
}
