#include "GamemodeCommon.as"

void onInit(CRules@ this)
{
	Gamemode::LoadGamemodes(0);
}

void onRestart(CRules@ this)
{
	Gamemode::LoadGamemodes(this.add_u32("gamemode index", 1));
}
