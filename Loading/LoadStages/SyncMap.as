#include "Map.as"

MapSyncer@ mapSyncer;

void onInit(CRules@ this)
{
	@mapSyncer = Map::getSyncer();
	this.set_string("loading message", "Deserializing map...");
}

void onTick(CRules@ this)
{
	if (isServer())
	{
		mapSyncer.ServerSync();
	}
	else
	{
		mapSyncer.ClientReceive();

		float progress = mapSyncer.getCurrentIndex() / float(Maths::Max(1, mapSyncer.getTotalPackets() - 2));
		this.set_f32("loading progress", progress);

		if (mapSyncer.isSynced())
		{
			print("Map synced!");

			this.RemoveScript("SyncMap.as");
			this.AddScript("InitBlockFaces.as");
		}
	}
}
