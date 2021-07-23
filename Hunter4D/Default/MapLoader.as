const int MINIMAP_WIDTH = 298;
const int MINIMAP_HEIGHT = 105;

bool LoadMap(CMap@ map, const string &in fileName)
{
	if (!isServer())
	{
		map.CreateTileMap(0, 0, 8.0f, "Sprites/world.png");
	}
	else
	{
		map.CreateTileMap(MINIMAP_WIDTH, MINIMAP_HEIGHT, 8.0f, "Sprites/world.png");
	}
	return true;
}

// void CalculateMinimapColour(CMap@ this, u32 offset, TileType tile, SColor &out col)
// {
// 	Vec2f pos = offsetToPos(offset);
// 	bool edge = pos.x == 0 || pos.y == 0 || pos.x == MINIMAP_WIDTH - 1 || pos.y == MINIMAP_HEIGHT - 1;
// 	col = edge ? SColor(255, 255, 0, 0) : color_black;
// }

// Vec2f offsetToPos(int offset)
// {
// 	Vec2f vec;
// 	vec.x = offset % MINIMAP_WIDTH;
// 	vec.y = Maths::Floor(offset / MINIMAP_WIDTH) % MINIMAP_HEIGHT;
// 	return vec;
// }
