#include "Loader.as"
#include "Map.as"


Map@ map;
uint sectionIndex = 0;
uint blocksPerSection = 50;

void onInit(CRules@ this)
{
	@map = Map::getMap();
	this.set_string("loading message", "Generating map...");
}

void onTick(CRules@ this)
{
	if (isServer())
	{
		// Initialize map
		if (sectionIndex == 0)
		{
			map = Map(Vec3f(32, 8, 32));
		}

		// Get start and end block index
		uint startIndex = sectionIndex * blocksPerSection;
		uint endIndex = Maths::Min(startIndex + blocksPerSection, map.blockCount);

		// Loop through blocks in this section
		for (uint i = startIndex; i < endIndex; i++)
		{
			Vec3f pos = map.indexToPos(i);
			u8 type = pos.y == 0 ? 1 : 0;
			map.SetBlock(i, type);
		}

		uint sectionCount = getSectionCount();

		// Set loading progress
		this.set_f32("loading progress", sectionIndex / float(Maths::Max(1, sectionCount - 2)));
		this.Sync("loading progress", true);

		if (sectionIndex < sectionCount - 1)
		{
			// Move onto next section
			sectionIndex++;
		}
		else
		{
			// Map generation complete
			print("Map generated");
			Map::getSyncer().AddRequestForEveryone();
			Loader::getLoader().NextStage();
		}
	}
	else
	{
		if (Map::getSyncer().hasPackets())
		{
			print("Map generated");
			Loader::getLoader().NextStage();
		}
	}
}

uint getSectionCount()
{
	return Maths::Ceil(map.blockCount / float(blocksPerSection));
}