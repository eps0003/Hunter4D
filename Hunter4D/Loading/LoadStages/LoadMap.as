#include "Map.as"
#include "sex.as"
#include "Utilities.as"

Map@ map;
//uint sectionIndex = 0;
//uint blocksPerSection = 2000;
//uint sectionCount;

uint size = mapData.size() / 6;
uint yOffset = MAP_SIZE.y * 0.5f;

void onInit(CRules@ this)
{
	this.addCommandID("map generated");

	onRestart(this);
}

void onRestart(CRules@ this)
{
	if (isServer())
	{
		@map = Map::getMap();
		map = Map(MAP_SIZE);
		//sectionIndex = 0;
		//sectionCount = Maths::Ceil(size / float(blocksPerSection));

		this.set_bool("map generated", false);
		this.Sync("map generated", true);
	}

	print("Begin generating map");
}

void onTick(CRules@ this)
{
	if (isServer())
	{
		uint last_block_index = 0;
		for (uint needle = 0; needle < mapData.size();)
		{
			uint amount = mapData[needle];
			
			for(uint i = 0; i < amount; i++)
			{
				uint index = (needle+1)+i*2;
				uint z = mapData[index];
				uint col = mapData[index + 1];
				SColor color = SColor(col);
				color.setAlpha(255);
				
				Vec3f pos = Vec3f((last_block_index % MAP_SIZE.x), z, int(last_block_index / MAP_SIZE.x));

				map.SetBlock(pos, color);
			}
			
			needle += amount*2+1;
			last_block_index++;
		}
		
		// Get start and end block index
		/*uint startIndex = sectionIndex * blocksPerSection;
		uint endIndex = Maths::Min(startIndex + blocksPerSection, size);

		// Loop through blocks in this section
		for (uint i = startIndex; i < endIndex; i++)
		{
			uint index = i * 6;

			Vec3f pos;
			pos.x = mapData[index + 0];
			pos.y = mapData[index + 2] - yOffset;
			pos.z = mapData[index + 1];

			SColor color;
			color.setRed(mapData[index + 3]);
			color.setGreen(mapData[index + 4]);
			color.setBlue(mapData[index + 5]);

			map.SetBlock(pos, color);
		}

		// Set loading progress
		float progress = sectionIndex / Maths::Max(1, sectionCount - 2);
		this.set_f32("map gen progress", progress);
		this.Sync("map gen progress", true);

		if (sectionIndex < sectionCount - 1)
		{
			// Print loading progress
			if (getGameTime() % getTicksASecond() == 0)
			{
				uint perc = Maths::Clamp01(progress) * 100;
				print("Generating map (" + perc + "%)");
			}

			// Move onto next section
			sectionIndex++;
		}
		else*/
		{
			// Map generation complete
			this.set_bool("map generated", true);
			this.Sync("map generated", true);

			this.SendCommand(this.getCommandID("map generated"), CBitStream(), true);
		}
	}

	if (isClient())
	{
		this.set_string("loading message", "Generating map...");
		this.set_f32("loading progress", this.get_f32("map gen progress"));
	}

	if (this.get_bool("map generated"))
	{
		print("Map generated!");
		this.RemoveScript("LoadMap.as");
		if (!isLocalHost())
		{
			this.AddScript("SyncMap.as");
		}
		else
		{
			this.AddScript("InitBlockFaces.as");
		}
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("map generated"))
	{
		this.set_bool("map generated", true);
	}
}
