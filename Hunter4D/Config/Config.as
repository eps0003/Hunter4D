namespace Config
{
	shared ConfigFile@ getConfig()
	{
		ConfigFile@ cfg;
		if (!getRules().get("config", @cfg))
		{
			@cfg = ConfigFile();
			if (!cfg.loadFile("../Cache/" + Config::getConfigName()))
			{
				cfg.add_f32("fov", 70.0f);
				cfg.add_f32("render_distance", 100.0f);
				cfg.add_f32("sensitivity", 1.0f);

				Config::SaveConfig(cfg);
			}
			getRules().set("config", @cfg);
		}
		return cfg;
	}

	shared void SaveConfig(ConfigFile cfg)
	{
		cfg.saveFile(Config::getConfigName());
	}

	shared string getConfigName()
	{
		return "Hunter4D.cfg";
	}
}
