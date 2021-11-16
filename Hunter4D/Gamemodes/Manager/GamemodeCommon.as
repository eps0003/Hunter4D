namespace Gamemode
{
	shared GamemodeManager@ getManager()
	{
		GamemodeManager@ manager;
		if (!getRules().get("gamemode manager", @manager))
		{
			@manager = GamemodeManager("gamemodes.cfg");
			getRules().set("gamemode manager", @manager);
		}
		return manager;
	}
}
