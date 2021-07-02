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
	uint chunksThisTick = Maths::Ceil(Maths::Pow(1.015f, Interpolation::getFPS()));

	int seconds = Maths::Ceil(secondsUntilDone(chunksThisTick, renderer.chunkCount, index));
	this.set_string("loading message", "[" + Maths::Floor(index / float(Maths::Max(1, renderer.chunkCount)) * 100) + "%] Generating chunks... (" + seconds + "s left)");

    for (uint i = 0; i < chunksThisTick; i++)
    {
        Chunk chunk(renderer, index);
        @renderer.chunks[index] = chunk;
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

	this.set_f32("loading progress", index / float(Maths::Max(1, renderer.chunkCount)));
}

float secondsUntilDone(uint thingsPerTick, uint totalThings, uint index)
{
	uint thingsASecond = thingsPerTick * getTicksASecond();
	float progress = 1 - index / Maths::Max(1, totalThings);
	return totalThings / Maths::Max(1, thingsASecond) * progress;
}
