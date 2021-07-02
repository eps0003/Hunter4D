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
}

void onTick(CRules@ this)
{
	uint blocksThisTick = Maths::Ceil(Interpolation::getFPS() / 0.03f);

	int seconds = Maths::Ceil(secondsUntilDone(blocksThisTick, map.blockCount, index));
	this.set_string("loading message", "[" + Maths::Floor(index / float(Maths::Max(1, map.blockCount)) * 100) + "%] Initializing block faces... (" + seconds + "s left)");

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

	this.set_f32("loading progress", index / float(Maths::Max(1, map.blockCount)));
}

float secondsUntilDone(uint thingsPerTick, uint totalThings, uint index)
{
	uint thingsASecond = thingsPerTick * getTicksASecond();
	float progress = 1 - index / Maths::Max(1, totalThings);
	return totalThings / Maths::Max(1, thingsASecond) * progress;
}
