#include "Command.as"
#include "Camera.as"

class RenderDistanceCommand : Command
{
	RenderDistanceCommand()
	{
		super("distance", "Change render distance.");
		AddAlias("renderdistance");
		AddAlias("dist");
	}

	void Execute(string[] args, CPlayer@ player)
	{
		if (!player.isMyPlayer()) return;

		Camera@ camera = Camera::getCamera();

		if (args.size() == 0)
		{
			client_AddToChat("Your current render distance is " + camera.getRenderDistance(), ConsoleColour::INFO);
		}
		else
		{
			float val = parseFloat(args[0]);
			if (val > 0)
			{
				camera.SetRenderDistance(val);
				client_AddToChat("Your render distance has been set to " + val, ConsoleColour::INFO);
			}
			else
			{
				client_AddToChat("Please specify a render distance larger than 0", ConsoleColour::ERROR);
			}
		}
	}
}