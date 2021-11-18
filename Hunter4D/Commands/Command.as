#include "CommandCommon.as"
#include "CommandManager.as"

shared class Command
{
	string[] aliases;
	string description;
	bool modOnly = false;

	Command(string name, string description, bool modOnly = false)
	{
		aliases.push_back(name);
		this.description = description;
		this.modOnly = modOnly;
	}

	void AddAlias(string name)
	{
		aliases.push_back(name);
	}

	bool canUse(CPlayer@ player)
	{
		return !modOnly || player.isMod();
	}

	void Execute(string[] args, CPlayer@ player) {}
}
