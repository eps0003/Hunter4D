#include "MapBuilder.as"

shared class MapManager
{
    MapBuilder@ currentMap;
    MapBuilder@ nextMap;

    void SetMap(MapBuilder@ map)
    {
        if (currentMap is null)
        {
            @currentMap = map;
        }

        @nextMap = map;
    }

    MapBuilder@ getCurrentMap()
    {
        return currentMap;
    }

    MapBuilder@ getNextMap()
    {
        return nextMap;
    }
}
