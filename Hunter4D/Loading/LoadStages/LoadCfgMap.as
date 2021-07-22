#include "Map.as"
#include "Utilities.as"

uint blocksPerSection = 5000;

Map@ map;
ConfigFile cfg;
uint[] data;
uint index;
uint needle;
uint size;

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

		index = 0;
		needle = 0;

		cfg.loadFile("Ephtracy.cfg");

		uint[] dimensions;
		cfg.readIntoArray_u32(dimensions, "size");
		map = Map(Vec3f(dimensions[0], dimensions[1], dimensions[2]));

		data.clear();
		cfg.readIntoArray_u32(data, "blocks");
		size = data.size();

		this.set_bool("map generated", false);
		this.Sync("map generated", true);
	}

	print("Begin generating map");
}

void onTick(CRules@ this)
{
	if (isServer())
	{
		for (uint i = 0; i < blocksPerSection && needle < size;)
		{
			uint val = data[needle];
			if (val > 0)
			{
				map.SetBlock(index++, val);
				i++;
			}
			else
			{
				index += data[++needle] + 1;
			}

			needle++;
		}

		// Set loading progress
		float progress = needle / Maths::Max(1, size);
		this.set_f32("map gen progress", progress);
		this.Sync("map gen progress", true);

		if (needle < size)
		{
			// Print loading progress
			if (getGameTime() % getTicksASecond() == 0)
			{
				uint perc = Maths::Clamp01(progress) * 100;
				print("Generating map (" + perc + "%)");
			}
		}
		else
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
		this.RemoveScript("LoadCfgMap.as");
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
