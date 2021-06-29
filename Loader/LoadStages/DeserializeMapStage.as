#include "LoadStage.as"
#include "Map.as"

class DeserializeMapStage : LoadStage
{
    bool loaded = false;
    private MapSyncer@ mapSyncer;

    DeserializeMapStage()
    {
        super("Receiving map...");
        @mapSyncer = Map::getMapSyncer();
    }

    void OnStart()
    {

    }

    void Load()
    {
        if (!isClient()) return;

        mapSyncer.ClientReceive();

        if (mapSyncer.isSynced())
        {
            loaded = true;
        }
    }

    void OnEnd()
    {

    }

    bool isLoaded()
    {
        return loaded;
    }
}
