#include "Map.as"

MapSyncer@ mapSyncer;

void onInit(CRules@ this)
{
	@mapSyncer = Map::getSyncer();

	onRestart(this);
}

void onRestart(CRules@ this)
{
	if (isServer())
	{
		mapSyncer.AddRequestForEveryone();
	}
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

		float progress = mapSyncer.getCurrentIndex() / Maths::Max(1, mapSyncer.getTotalPackets() - 2);
		this.set_f32("loading progress", progress);
		this.set_string("loading message", "Deserializing map...");

		if (mapSyncer.isSynced())
		{
			print("Map synced!");

			this.RemoveScript("SyncMap.as");
			this.AddScript("InitBlockFaces.as");
		}
	}
}
