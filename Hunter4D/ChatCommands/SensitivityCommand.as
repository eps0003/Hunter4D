#include "Command.as"
#include "Mouse.as"

class SensitivityCommand : Command
{
	SensitivityCommand()
	{
		super("sensitivity", "Change mouse sensitivity.");
		AddAlias("sens");
	}

	void Execute(string[] args, CPlayer@ player)
	{
		if (!player.isMyPlayer()) return;

		Mouse@ mouse = Mouse::getMouse();

		if (args.size() == 0)
		{
			client_AddToChat("Your current mouse sensitivity is " + mouse.getSensitivity(), ConsoleColour::INFO);
		}
		else
		{
			float val = parseFloat(args[0]);
			if (val > 0)
			{
				mouse.SetSensitivity(val);
				client_AddToChat("Your mouse sensitivity has been set to " + val, ConsoleColour::INFO);
			}
			else
			{
				client_AddToChat("Please specify a mouse sensitivity larger than 0", ConsoleColour::ERROR);
			}
		}
	}
}