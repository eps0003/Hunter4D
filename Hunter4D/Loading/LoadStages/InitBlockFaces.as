#include "Map.as"
#include "Utilities.as"

#define CLIENT_ONLY

Map@ map;
MapRenderer@ renderer;
uint index = 0;
uint x = 0;
uint y = 0;
uint z = 0;

void onInit(CRules@ this)
{
	@map = Map::getMap();
	@renderer = Map::getRenderer();
	index = 0;
	x = 0;
	y = 0;
	z = 0;

	this.set_string("loading message", "Initializing block faces...");
}

void onRestart(CRules@ this)
{
	this.RemoveScript("InitBlockFaces.as");
}

void onTick(CRules@ this)
{
	uint blocksThisTick = getFPS() * 30;
	uint i = 0;

	this.set_f32("loading progress", index / Maths::Max(1, map.blockCount));

	for (; y < map.dimensions.y; y++)
	{
		for (; z < map.dimensions.z; z++)
		{
			for (; x < map.dimensions.x; x++)
			{
				renderer.UpdateBlockFaces(index, x, y, z);

				if (++index >= map.blockCount)
				{
					print("Block faces initialized!");

					this.RemoveScript("InitBlockFaces.as");
					this.AddScript("GenerateChunks.as");

					return;
				}

				if (++i >= blocksThisTick)
				{
					return;
				}
			}

			x = 0;
		}

		z = 0;
	}
}
