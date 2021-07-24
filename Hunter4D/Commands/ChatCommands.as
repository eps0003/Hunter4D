#include "SensitivityCommand.as"
#include "FOVCommand.as"
#include "RenderDistanceCommand.as"

Command@[] commands = {
	SensitivityCommand(),
	FOVCommand(),
	RenderDistanceCommand()
};

void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
	CContextMenu@ configMenu = Menu::addContextMenu(menu, getTranslatedString("Hunter3D Commands"));
	CPlayer@ player = getLocalPlayer();

	for (uint i = 0; i < commands.size(); i++)
	{
		Command@ command = commands[i];
		if (!command.modOnly || player.isMod())
		{
			Menu::addInfoBox(configMenu, getTranslatedString("!" + command.aliases[0]), getTranslatedString(command.description));
		}
	}
}

bool onServerProcessChat(CRules@ this, const string &in textIn, string &out textOut, CPlayer@ player)
{
	Command@ command;
	string[] args;
	if (processCommand(textIn, command, args) && (!command.modOnly || player.isMod()))
	{
		command.Execute(args, player);
	}
	return true;
}

bool onClientProcessChat(CRules@ this, const string& in textIn, string& out textOut, CPlayer@ player)
{
	Command@ command;
	string[] args;
	if (processCommand(textIn, command, args))
	{
		if (!command.modOnly || player.isMod())
		{
			command.Execute(args, player);
		}
		else if (player.isMyPlayer())
		{
			client_AddToChat("Only admins can use this command", ConsoleColour::ERROR);
		}
		return false;
	}
	return true;
}

bool processCommand(string text, Command@ &out command, string[] &out args)
{
	// Reduce all spaces down to one space
	while (text.find("  ") > -1)
	{
		text = text.replace("  ", " ");
	}

	// Remove space at start
	if (text.find(" ") == 0)
	{
		text = text.substr(1);
	}

	// Remove space at end
	uint lastIndex = text.size() - 1;
	if (text.findLast(" ") == lastIndex)
	{
		text = text.substr(0, lastIndex);
	}

	if (text.find("!") == 0)
	{
		args = text.split(" ");
		string cmd = args[0].toLower().substr(1);

		args.removeAt(0);

		for (uint i = 0; i < commands.size(); i++)
		{
			@command = commands[i];
			if (command.aliases.find(cmd) > -1)
			{
				return true;
			}
		}
	}

	return false;
}
