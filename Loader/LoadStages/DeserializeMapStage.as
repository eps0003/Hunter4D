#include "Loader.as"
#include "Map.as"

void onTick(CRules@ this)
{
    MapSyncer@ mapSyncer = Map::getMapSyncer();

    mapSyncer.ClientReceive();

    if (mapSyncer.isSynced())
    {
        Loader::getLoader().NextStage();
    }
}
