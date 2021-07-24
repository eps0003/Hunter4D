#include "Command.as"
#include "Actor.as"

class KillCommand : Command
{
	KillCommand()
	{
		super("kill", "Kill a player.", true);
	}

	void Execute(string[] args, CPlayer@ player)
	{
		if (args.size() == 0)
		{
			if (player.isMyPlayer())
			{
				client_AddToChat("Please specify a player to kill", ConsoleColour::ERROR);
			}
		}
		else
		{
			string username = args[0];
			CPlayer@ victim = getPlayerByUsername(username);
			if (victim is null)
			{
				if (player.isMyPlayer())
				{
					client_AddToChat("A player with the username '" + username + "' doesn't exist", ConsoleColour::ERROR);
				}
			}
			else
			{
				if (isServer())
				{
					victim.getBlob().server_Die();
				}

				if (player.isMyPlayer())
				{
					client_AddToChat(victim.getUsername() + " has been killed", ConsoleColour::INFO);
				}
			}
		}
	}
}