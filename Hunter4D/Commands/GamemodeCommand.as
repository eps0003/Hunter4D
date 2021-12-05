#include "Command.as"
#include "GamemodeManager.as"
#include "Utilities.as"

class GamemodeCommand : Command
{
	GamemodeCommand()
	{
		super("gamemode", "Load a gamemode.", true);
		AddAlias("mode");
		AddAlias("gm");
	}

	void Execute(string[] args, CPlayer@ player)
	{
		GamemodeManager@ manager = Gamemode::getManager();

		if (args.size() == 0)
		{
			if (player.isMyPlayer())
			{
				client_AddToChat("Please specify gamemode to load: " + join(manager.getGamemodeNames(), ", "), ConsoleColour::ERROR);
			}
		}
		else
		{
			string gamemodeName = args[0];
			string gamemode = manager.findGamemodeCaseInsensitive(gamemodeName + ".as");
			if (gamemode == "")
			{
				if (player.isMyPlayer())
				{
					client_AddToChat("A gamemode by the name of '" + gamemode + "' doesn't exist", ConsoleColour::ERROR);
				}
			}
			else
			{
				if (isServer())
				{
					manager.SetGamemode(gamemode);
					LoadNextMap();
				}

				if (player.isMyPlayer())
				{
					client_AddToChat(trimFileExtension(script) + " has been loaded", ConsoleColour::INFO);
				}
			}
		}
	}
}
