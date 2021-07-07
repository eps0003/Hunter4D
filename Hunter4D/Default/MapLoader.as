bool LoadMap(CMap@ map, const string&in fileName)
{
	if (isServer())
	{
		map.CreateTileMap(1, 1, 1.0f, "Sprites/world.png");
	}
	return true;
}
