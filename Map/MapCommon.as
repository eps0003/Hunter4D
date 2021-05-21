namespace Map
{
	Map@ getMap()
	{
		Map@ map;
		if (!getRules().get("map", @map))
		{
			@map = Map(Vec3f(32, 8, 32));
			getRules().set("map", @map);
		}
		return map;
	}
}
