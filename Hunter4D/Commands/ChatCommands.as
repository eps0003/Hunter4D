#include "CommandManager.as"
#include "SensitivityCommand.as"
#include "FOVCommand.as"
#include "RenderDistanceCommand.as"
#include "KillCommand.as"

CommandManager@ manager;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	@manager = Commands::getManager();

	manager.RegisterCommand(SensitivityCommand());
	manager.RegisterCommand(FOVCommand());
	manager.RegisterCommand(RenderDistanceCommand());
	manager.RegisterCommand(KillCommand());
}

void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
	CContextMenu@ contextMenu = Menu::addContextMenu(menu, getTranslatedString("Chat Commands"));
	CPlayer@ player = getLocalPlayer();

	Command@[] commands = manager.getCommands();
	for (uint i = 0; i < commands.size(); i++)
	{
		Command@ command = commands[i];
		if (command.canUse(player))
		{
			Menu::addInfoBox(contextMenu, getTranslatedString("!" + command.aliases[0]), getTranslatedString(command.description));
		}
	}
}

bool onServerProcessChat(CRules@ this, const string &in textIn, string &out textOut, CPlayer@ player)
{
	Command@ command;
	string[] args;
	if (manager.processCommand(textIn, command, args) && command.canUse(player))
	{
		command.Execute(args, player);
	}
	return true;
}

bool onClientProcessChat(CRules@ this, const string& in textIn, string& out textOut, CPlayer@ player)
{
	Command@ command;
	string[] args;
	if (manager.processCommand(textIn, command, args))
	{
		if (command.canUse(player))
		{
			command.Execute(args, player);
		}
		else if (player.isMyPlayer())
		{
			client_AddToChat("You are unable to use this command", ConsoleColour::ERROR);
		}
		return false;
	}
	return true;
}
