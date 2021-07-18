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

	for (uint i = 0; i < commands.size(); i++)
	{
		Command@ command = commands[i];
		Menu::addInfoBox(configMenu, getTranslatedString("!" + command.aliases[0]), getTranslatedString(command.description));
	}
}

bool onServerProcessChat(CRules@ this, const string &in textIn, string &out textOut, CPlayer@ player)
{
	ProcessCommand(textIn, player);
	return true;
}

bool onClientProcessChat(CRules@ this, const string& in textIn, string& out textOut, CPlayer@ player)
{
	return ProcessCommand(textIn, player);
}

bool ProcessCommand(string text, CPlayer@ player)
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
		string[] args = text.split(" ");
		string cmd = args[0].toLower().substr(1);

		args.removeAt(0);

		for (uint i = 0; i < commands.size(); i++)
		{
			Command@ command = commands[i];
			if (command.aliases.find(cmd) > -1)
			{
				command.Execute(args, player);
				return false;
			}
		}
	}

	return true;
}
