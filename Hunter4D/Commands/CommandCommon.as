namespace Commands
{
	shared CommandManager@ getManager()
	{
		CommandManager@ manager;
		if (!getRules().get("command manager", @manager))
		{
			@manager = CommandManager();
			getRules().set("command manager", @manager);
		}
		return manager;
	}
}
