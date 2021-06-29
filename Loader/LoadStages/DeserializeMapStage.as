#include "Loader.as"
#include "Map.as"

#define CLIENT_ONLY

MapSyncer@ mapSyncer;

void onInit(CRules@ this)
{
    @mapSyncer = Map::getMapSyncer();
    this.set_string("loading message", "Deserializing map...");
}

void onTick(CRules@ this)
{
    mapSyncer.ClientReceive();

    float progress = mapSyncer.getCurrentPacketIndex() / float(mapSyncer.getTotalPackets() - 2);
    this.set_f32("loading progress", progress);

    if (mapSyncer.isSynced())
    {
        print("Map synced!");
        Loader::getLoader().NextStage();
    }
}
