#include "Map.as"
#include "Interpolation.as"

#define CLIENT_ONLY

Map@ map;
MapRenderer@ renderer;
uint index = 0;

void onInit(CRules@ this)
{
	@map = Map::getMap();
	@renderer = Map::getRenderer();

	this.set_string("loading message", "Initializing block faces...");
}

void onTick(CRules@ this)
{
	uint blocksThisTick = Maths::Ceil(Interpolation::getFPS() / 0.03f);
	print("" + blocksThisTick);

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
