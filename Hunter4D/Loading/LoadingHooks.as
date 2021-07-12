#include "Loading.as"

Loading@ loading;

void onInit(CRules@ this)
{
	this.addCommandID("player loaded");

	onRestart(this);
}

void onRestart(CRules@ this)
{
	@loading = Loading::getLoading();
	loading.SetAllPlayersLoaded(false);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	loading.SetPlayerLoaded(player, false);
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
    if (!isClient() && cmd == this.getCommandID("player loaded"))
    {
		u16 playerId;
		if (!params.saferead_netid(playerId)) return;

		CPlayer@ player = getPlayerByNetworkId(playerId);
		if (player is null) return;

		loading.SetPlayerLoaded(player, true);
    }
}
