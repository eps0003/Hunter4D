string prevMapName;

void onInit(CRules@ this)
{
	prevMapName = getMapName();
}

void onRestart(CRules@ this)
{
	string mapName = getMapName();
	this.set_bool("nextmap", mapName != prevMapName);
	prevMapName = mapName;
}

string getMapName()
{
	string mapName = getMap().getMapName();
	int lastSlash = mapName.findLast("/");
	return mapName.substr(lastSlash + 1);
}
