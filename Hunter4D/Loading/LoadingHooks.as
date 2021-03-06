#include "Loading.as"
#include "Utilities.as"

void onInit(CRules@ this)
{
	this.addCommandID("player loaded");

	onRestart(this);
}

void onRestart(CRules@ this)
{
	Loading::SetAllPlayersLoaded(false);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	Loading::SetPlayerLoaded(player, false);
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isClient() && cmd == this.getCommandID("player loaded"))
	{
		CPlayer@ player;
		if (!saferead_player(params, @player)) return;

		Loading::SetPlayerLoaded(player, true);
	}
}
