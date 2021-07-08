#include "Map.as"
#include "Utilities.as"

#define CLIENT_ONLY

Map@ map;
MapRenderer@ renderer;
uint index = 0;

void onInit(CRules@ this)
{
	@map = Map::getMap();
	@renderer = Map::getRenderer();
	index = 0;

	this.set_string("loading message", "Initializing block faces...");
}

void onRestart(CRules@ this)
{
	this.RemoveScript("InitBlockFaces.as");
}

void onTick(CRules@ this)
{
	uint blocksThisTick = getFPS() * 30;

	for (uint i = 0; i < blocksThisTick; i++)
	{
		renderer.UpdateBlockFaces(index);

		index++;
		if (index >= map.blockCount)
		{
			print("Block faces initialized!");

			this.RemoveScript("InitBlockFaces.as");
			this.AddScript("GenerateChunks.as");

			break;
		}
	}

	this.set_f32("loading progress", index / Maths::Max(1, map.blockCount));
}
