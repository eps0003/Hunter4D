#include "Map.as"

Map@ map;
uint sectionIndex = 0;
uint blocksPerSection = 8000;
uint sectionCount;

void onInit(CRules@ this)
{
	if (isServer())
	{
		@map = Map::getMap();
		map = Map(Vec3f(256, 64, 256));
		sectionCount = Maths::Ceil(map.blockCount / float(blocksPerSection));
	}

	this.set_string("loading message", "Generating map...");
}

void onTick(CRules@ this)
{
	if (isServer())
	{
		// Get start and end block index
		uint startIndex = sectionIndex * blocksPerSection;
		uint endIndex = Maths::Min(startIndex + blocksPerSection, map.blockCount);

		// Loop through blocks in this section
		for (uint i = startIndex; i < endIndex; i++)
		{
			Vec3f pos = map.indexToPos(i);
			u8 type = (pos.x + pos.y + pos.z) % 2 == 0 ? 1 : 0;
			map.SetBlock(i, type);
		}

		// Set loading progress
		this.set_f32("map gen progress", sectionIndex / Maths::Max(1, sectionCount - 2));
		this.Sync("map gen progress", true);

		if (sectionIndex < sectionCount - 1)
		{
			// Move onto next section
			sectionIndex++;
		}
		else
		{
			// Map generation complete
			this.set_bool("map generated", true);
			this.Sync("map generated", true);
		}
	}

	if (isClient())
	{
		this.set_f32("loading progress", this.get_f32("map gen progress"));
	}

	if (this.get_bool("map generated"))
	{
		print("Map generated!");
		this.RemoveScript("GenerateMap.as");
		this.AddScript("SyncMap.as");
	}
}
