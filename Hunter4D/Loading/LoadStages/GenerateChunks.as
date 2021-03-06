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

	this.set_string("loading message", "Generating chunks...");
}

void onRestart(CRules@ this)
{
	this.RemoveScript("GenerateChunks.as");
}

void onTick(CRules@ this)
{
	uint chunksThisTick = getFPS() * Maths::Pow(renderer.chunkDimension, -3) * 300;

	for (uint i = 0; i < chunksThisTick; i++)
	{
		renderer.SetChunk(index, Chunk(renderer, index));

		index++;
		if (index >= renderer.chunkCount)
		{
			print("Chunks generated!");

			@renderer.tree = Tree();

			this.RemoveScript("GenerateChunks.as");
			this.RemoveScript("LoadingScreen.as");
			this.AddScript("Client.as");

			Loading::SetMyPlayerLoaded(true);

			break;
		}
	}

	this.set_f32("loading progress", index / Maths::Max(1, renderer.chunkCount));
}
