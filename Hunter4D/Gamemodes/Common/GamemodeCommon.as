namespace Gamemode
{
	shared void LoadGamemodes(uint index)
	{
		ConfigFile@ cfg = Gamemode::getConfig();

		string[] scripts;
		if (!cfg.readIntoArray_string(scripts, "gamemodes"))
		{
			warn("No gamemodes were specified in " + Gamemode::getConfigName());
			return;
		}

		getRules().set("gamemode scripts", scripts);
		getRules().AddScript(scripts[index % scripts.size()]);
	}

	shared ConfigFile@ getConfig()
	{
		ConfigFile@ cfg;
		if (!getRules().get("gamemodes config", @cfg))
		{
			@cfg = ConfigFile();
			cfg.loadFile(Gamemode::getConfigName());
			getRules().set("gamemodes config", @cfg);
		}
		return cfg;
	}

	shared string getConfigName()
	{
		return "gamemodes.cfg";
	}
}
