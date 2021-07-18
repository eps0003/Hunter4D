namespace Config
{
	shared ConfigFile@ getConfig()
	{
		ConfigFile@ cfg;
		if (!getRules().get("config", @cfg))
		{
			@cfg = ConfigFile();
			if (!cfg.loadFile("../Cache/Hunter4D.cfg"))
			{
				// Set default values
				cfg.add_f32("fov", 70.0f);
				cfg.add_f32("render_distance", 150.0f);
				cfg.add_f32("sensitivity", 1.0f);

				// Save to cache
				cfg.saveFile("Hunter4D.cfg");
				print("Initialized config!");
			}
			getRules().set("config", @cfg);
		}
		return cfg;
	}

	shared void SaveConfig(ConfigFile cfg)
	{
		cfg.saveFile("Hunter4D.cfg");
		print("Saved config!");
	}
}
