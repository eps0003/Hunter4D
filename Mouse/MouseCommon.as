namespace Mouse
{
	Mouse@ getMouse()
	{
		Mouse@ mouse;
		if (!getRules().get("mouse", @mouse))
		{
			@mouse = Mouse();
			getRules().set("mouse", mouse);
		}
		return mouse;
	}
}
