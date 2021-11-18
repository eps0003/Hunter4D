#include "GamemodeCommon.as"
#include "Utilities.as"

shared class GamemodeManager
{
	private string[] gamemodes;
	private uint gamemodeIndex = 0;
	private CRules@ rules = getRules();
	private Random random(Time());
	private string previousScript;

	GamemodeManager(string configPath)
	{
		if (isServer())
		{
			LoadGamemodes(configPath);

			if (!gamemodes.empty())
			{
				SetGamemode(0);
			}
		}
	}

	private void LoadGamemodes(string configPath)
	{
		ConfigFile cfg;
		if (!cfg.loadFile(configPath))
		{
			error("Could not load gamemodes config file: " + configPath);
			return;
		}

		string[] scripts;
		if (!cfg.readIntoArray_string(scripts, "gamemodes"))
		{
			error("No gamemodes were specified in " + configPath);
			return;
		}

		gamemodes = scripts;
	}

	string getCurrentGamemode()
	{
		return rules.get_string("current gamemode");
	}

	string getGamemode(uint index)
	{
		return gamemodes[index % gamemodes.size()];
	}

	void SetGamemode(uint index, bool updateIndex = true)
	{
		index = index % gamemodes.size();
		if (updateIndex)
		{
			gamemodeIndex = index;
		}
		SetCurrentGamemode(gamemodes[index]);
	}

	void SetGamemode(string name, bool updateIndex = true)
	{
		if (updateIndex)
		{
			// Try find the gamemode past the current gamemode index
			// This is so if the gamemode is listed twice in the cfg,
			// it will pick the next occurrence rather than always picking the first
			int index = gamemodes.find(gamemodeIndex, name);
			if (index < 0)
			{
				// If that fails, try find the gamemode anywhere in the list
				index = gamemodes.find(name);
			}

			if (index > -1)
			{
				gamemodeIndex = index;
			}
		}

		SetCurrentGamemode(name);
	}

	void SetNextGamemode()
	{
		SetGamemode(gamemodeIndex + 1);
	}

	void SetRandomGamemode(bool updateIndex = true)
	{
		uint index = random.NextRanged(gamemodes.size());
		SetGamemode(index, updateIndex);
	}

	void InitCurrentGamemode()
	{
		rules.RemoveScript(previousScript);

		string script = getCurrentGamemode();
		rules.AddScript(script);

		previousScript = script;

		print("Gamemode: " + trimFileExtension(script));
	}

	private void SetCurrentGamemode(string name)
	{
		rules.set_string("current gamemode", name);
		rules.Sync("current gamemode", true);
	}
}