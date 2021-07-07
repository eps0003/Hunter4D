#include "Blocks.as"

void onInit(CRules@ this)
{
	onRestart(this);
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

	Render::RemoveScript(this.get_s32("render script id"));

	this.RemoveScript("Client.as");
	this.RemoveScript("SyncMap.as");

	this.AddScript("LoadMap.as");
	this.AddScript("LoadingScreen.as");
}
