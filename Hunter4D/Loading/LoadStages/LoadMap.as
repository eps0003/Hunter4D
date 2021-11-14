#include "MapBuilder.as"

MapManager@ mapManager;
MapBuilder@ mapBuilder;
bool firstAttempt;

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
		@mapBuilder = null;

		firstAttempt = true;

		this.set_bool("map generated", false);
		this.Sync("map generated", true);

		this.set_bool("map generation issue", false);
		this.Sync("map generation issue", true);
	}

	if (isClient())
	{
		print("Begin generating map");
	}
}

void onTick(CRules@ this)
{
	if (isServer())
	{
		bool wasNull = mapBuilder is null;
		@mapBuilder = mapManager.getCurrentMap();

		if (mapBuilder is null)
		{
			if (firstAttempt)
			{
				firstAttempt = false;
			}
			else
			{
				error("The map is unable to generate because a map hasn't been set");

				this.set_bool("map generation issue", true);
				this.Sync("map generation issue", true);

				this.RemoveScript("LoadMap.as");
			}
			return;
		}
		else if (wasNull)
		{
			print("Begin generating map");
			mapBuilder.Init();
		}

		this.set_bool("map generated", false);
		this.Sync("map generated", true);

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
		if (this.get_bool("map generation issue"))
		{
			error("An error occurred when generating the map on the server");
			this.set_string("loading message", "Error generating map. Please contact server host");
			this.RemoveScript("LoadMap.as");
			return;
		}
		else
		{
			this.set_string("loading message", "Generating map...");
			this.set_f32("loading progress", this.get_f32("map gen progress"));
		}
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
