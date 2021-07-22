#include "MapBuilder.as"

MapManager@ mapManager;
MapBuilder@ mapBuilder;

void onInit(CRules@ this)
{
	this.addCommandID("map generated");
	onRestart(this);
}

void onRestart(CRules@ this)
{
	if (isServer())
	{
		@mapManager = Map::getManager();
		@mapBuilder = mapManager.getCurrentMap();

		if (mapBuilder is null)
		{
			error("The map is unable to generate because a map hasn't been set");
			this.RemoveScript("LoadCfgMap.as");
			return;
		}

		mapBuilder.Init();

		this.set_bool("map generated", false);
		this.Sync("map generated", true);
	}

	print("Begin generating map");
}

void onTick(CRules@ this)
{
	if (isServer())
	{
		mapBuilder.Load();

		// Set loading progress
		float progress = mapBuilder.getProgress();
		this.set_f32("map gen progress", progress);
		this.Sync("map gen progress", true);

		if (!mapBuilder.isLoaded())
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
