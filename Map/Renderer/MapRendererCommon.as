namespace MapRenderer
{
	MapRenderer@ getRenderer()
	{
		MapRenderer@ renderer;
		if (!getRules().get("map renderer", @renderer))
		{
			@renderer = MapRenderer();
			getRules().set("map renderer", renderer);
		}
		return renderer;
	}
}
