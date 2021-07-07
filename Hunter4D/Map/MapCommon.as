namespace Map
{
	Map@ getMap()
	{
		Map@ map;
		if (!getRules().get("map", @map))
		{
			@map = Map();
			getRules().set("map", @map);
		}
		return map;
	}

	MapSyncer@ getSyncer()
	{
		MapSyncer@ syncer;
		if (!getRules().get("map syncer", @syncer))
		{
			@syncer = MapSyncer();
			getRules().set("map syncer", @syncer);
		}
		return syncer;
	}

	MapRenderer@ getRenderer()
	{
		MapRenderer@ renderer;
		if (!getRules().get("map renderer", @renderer))
		{
			@renderer = MapRenderer();
			getRules().set("map renderer", @renderer);
		}
		return renderer;
	}
}
