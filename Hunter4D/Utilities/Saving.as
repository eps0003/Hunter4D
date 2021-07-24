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
		Menu::addContextItem(menu, getTranslatedString("Save Hunter3D Map"), "Saving.as", "void SaveMap()");
	}
}

void SaveMap()
{
	Menu::CloseAllMenus();

	string data;
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

			data += block.color + ";";
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
