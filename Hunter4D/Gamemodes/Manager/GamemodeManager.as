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
		LoadGamemodes(configPath);

		if (isServer() && !gamemodes.empty())
		{
			SetGamemode(0);
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

	string[] getGamemodeNames()
	{
		string[] names;
		for (uint i = 0; i < gamemodes.size(); i++)
		{
			names.push_back(trimFileExtension(gamemodes[i]));
		}
		return names;
	}

	string findGamemodeCaseInsensitive(string gamemode)
	{
		for (uint i = 0; i < gamemodes.size(); i++)
		{
			if (gamemodes[i].toLower() == gamemode.toLower())
			{
				return gamemodes[i];
			}
		}
		return "";
	}

	void LoadGamemode(uint index, bool updateIndex = true)
	{
		index = index % gamemodes.size();
		if (updateIndex)
		{
			gamemodeIndex = index;
		}
		ApplyGamemode(gamemodes[index]);
	}

	void LoadGamemode(string name, bool updateIndex = true)
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

		ApplyGamemode(name);
	}

	void LoadNextGamemode()
	{
		LoadGamemode(gamemodeIndex + 1);
	}

	void LoadRandomGamemode(bool different = true, bool updateIndex = true)
	{
		uint index;
		uint count = gamemodes.size();

		do
		{
			index = random.NextRanged(count);
		} while(different && count > 1 && index == gamemodeIndex);

		LoadGamemode(index, updateIndex);
	}

	void InitCurrentGamemode()
	{
		rules.RemoveScript(previousScript);

		string script = getCurrentGamemode();
		rules.AddScript(script);

		previousScript = script;

		print("Gamemode: " + trimFileExtension(script));
	}

	private void ApplyGamemode(string name)
	{
		rules.set_string("current gamemode", name);
		rules.Sync("current gamemode", true);
		LoadNextMap();
	}
}
