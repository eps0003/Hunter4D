#include "MapBuilder.as"

shared class MapManager
{
	private MapBuilder@ currentMap;
	MapBuilder@ nextMap;

	void SetMap(MapBuilder@ map)
	{
		@currentMap = map;
	}

	MapBuilder@ getCurrentMap()
	{
		return currentMap;
	}
}
