#include "Blocks.as"

void onInit(CRules@ this)
{
	onRestart(this);
	InitDefaultMap();
	Blocks::LoadBlocks();
}

void onRestart(CRules@ this)
{
	this.set("camera", null);
	this.set("mouse", null);
	this.set("map", null);
	this.set("map syncer", null);
	this.set("map renderer", null);
	this.set("objects", null);
	this.set("actors", null);

	this.AddScript("LoadMap.as");
	this.AddScript("LoadingScreen.as");
}

void InitDefaultMap()
{
	CMap@ map = getMap();

	map.topBorder = false;
	map.bottomBorder = false;
	map.leftBorder = false;
	map.rightBorder = false;
	map.legacyTileVariations = false;
	map.legacyTileEffects = false;
	map.legacyTileDestroy = false;
	map.legacyTileMinimap = false;

	map.SetBorderColourLeft(0);
	map.SetBorderColourRight(0);
	map.SetBorderColourTop(0);
	map.SetBorderColourBottom(0);
	map.SetBorderFadeWidth(0);

	map.MakeMiniMap();
}
