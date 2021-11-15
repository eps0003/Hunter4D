#include "GamemodeManager.as"

GamemodeManager@ manager;

void onInit(CRules@ this)
{
	@manager = Gamemode::getManager();
	onRestart(this);
}

void onRestart(CRules@ this)
{
	manager.InitCurrentGamemode();
}
