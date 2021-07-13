#include "Loading.as"

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
		u16 playerId;
		if (!params.saferead_netid(playerId)) return;

		CPlayer@ player = getPlayerByNetworkId(playerId);
		if (player is null) return;

		Loading::SetPlayerLoaded(player, true);
	}
}
