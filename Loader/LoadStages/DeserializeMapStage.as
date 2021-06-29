#include "Loader.as"
#include "Map.as"

#define CLIENT_ONLY

MapSyncer@ mapSyncer;

void onInit(CRules@ this)
{
    @mapSyncer = Map::getMapSyncer();
}

void onTick(CRules@ this)
{
    mapSyncer.ClientReceive();

    if (mapSyncer.isSynced())
    {
        print("Map synced!");
        Loader::getLoader().NextStage();
    }
    else
    {
        print("Syncing map...");
    }
}
