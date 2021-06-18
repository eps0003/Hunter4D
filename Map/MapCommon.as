namespace Map
{
	Map@ getMap()
	{
		Map@ map;
		if (!getRules().get("map", @map))
		{
			@map = Map(Vec3f(32, 8, 32));
			Map::SetMap(map);
		}
		return map;
	}

	void SetMap(Map@ map)
	{
		getRules().set("map", @map);
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
