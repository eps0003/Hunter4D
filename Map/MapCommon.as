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

	MapSyncer@ getMapSyncer()
	{
		MapSyncer@ syncer;
		if (!getRules().get("map syncer", @syncer))
		{
			@syncer = MapSyncer();
			getRules().set("map syncer", @syncer);
		}
		return syncer;
	}
}
