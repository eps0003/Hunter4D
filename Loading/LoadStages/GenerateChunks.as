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

	this.set_string("loading message", "Generating chunks...");
}

void onTick(CRules@ this)
{
	uint chunksThisTick = Interpolation::getFPS() * 0.05f;

    for (uint i = 0; i < chunksThisTick; i++)
    {
        @renderer.chunks[index] = Chunk(renderer, index);

        index++;
        if (index >= renderer.chunkCount)
        {
            print("Chunks generated!");

            this.RemoveScript("GenerateChunks.as");
			this.RemoveScript("LoadingScreen.as");
			this.AddScript("Client.as");

            break;
        }
    }

	this.set_f32("loading progress", index / Maths::Max(1, renderer.chunkCount));
}
