#include "Loader.as"
#include "Map.as"

void onTick(CRules@ this)
{
	if (isServer())
	{
		Map@ map = Map::getMap();

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
