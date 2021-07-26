#include "Map.as"
#include "Loading.as"

#define CLIENT_ONLY

Map@ map;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	@map = Map::getMap();
}

void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
	if (Loading::isMyPlayerLoaded())
	{
		CContextMenu@ submenu = Menu::addContextMenu(menu, "Save Hunter3D Map");
		Menu::addContextItem(submenu, getTranslatedString("Save with block damage"), "Saving.as", "void SaveMapWithDamage()");
		Menu::addContextItem(submenu, getTranslatedString("Save without block damage"), "Saving.as", "void SaveMapWithoutDamage()");
	}
}

uint encodeBlock(SColor block, bool damage)
{
	if (damage)
	{
		return block.color;
	}

	return (block.getRed() << 17) | (block.getGreen() << 9) | (block.getBlue() << 1) | 1;
}

void SaveMapWithDamage()
{
	SaveMap(true);
}

void SaveMapWithoutDamage()
{
	SaveMap(false);
}

void SaveMap(bool damage)
{
	Menu::CloseAllMenus();

	string data = (damage ? "1" : "0") + ";";
	bool prevVisible = true;
	uint lastVisibleIndex = 0;

	for (uint i = 0; i < map.blockCount; i++)
	{
		SColor block = map.getBlock(i);
		bool visible = map.isVisible(block);

		if (visible)
		{
			if (!prevVisible)
			{
				data += "0;" + (i - lastVisibleIndex - 2) + ";";
			}

			data += encodeBlock(block, damage) + ";";
			lastVisibleIndex = i;
		}

		prevVisible = visible;
	}

	ConfigFile cfg;
	cfg.add_string("size", map.dimensions.x + ";" + map.dimensions.y + ";" + map.dimensions.z + ";");
	cfg.add_string("blocks", data);
	cfg.saveFile("Map.cfg");

	client_AddToChat("The map has been saved to Cache/Map.cfg");
}
