#include "Camera.as"
#include "Mouse.as"

Camera@ camera;
Mouse@ mouse;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	@camera = Camera::getCamera();
	@mouse = Mouse::getMouse();
}

bool onClientProcessChat(CRules@ this, const string& in textIn, string& out textOut, CPlayer@ player)
{
	string text = textIn;
	while (text.find("  ") > -1)
	{
		text = text.replace("  ", " ");
	}

	string[] args = text.split(" ");
	string cmd = args[0].toLower();

	args.removeAt(0);

	if (cmd == "!sensitivity" || cmd == "!sens")
	{
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
	else if (cmd == "!fov")
	{
		if (args.size() == 0)
		{
			client_AddToChat("Your current field of view is " + camera.getFOV(), ConsoleColour::INFO);
		}
		else
		{
			float val = parseFloat(args[0]);
			if (val > 0 && val <= 140)
			{
				camera.SetFOV(val);
				client_AddToChat("Your field of view has been set to " + val, ConsoleColour::INFO);
			}
			else
			{
				client_AddToChat("Please specify a field of view between 0 and 140", ConsoleColour::ERROR);
			}
		}
	}
	else if (cmd == "!distance")
	{
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
	else
	{
		return true;
	}

	return false;
}
