#include "SandboxActor.as"
#include "SpectatorActor.as"
#include "Loading.as"

#define SERVER_ONLY

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	this.SetCurrentState(GAME);
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("player loaded"))
	{
		u16 playerId;
		if (!params.saferead_netid(playerId)) return;

		CPlayer@ player = getPlayerByNetworkId(playerId);
		if (player is null) return;

		SpawnPlayer(player);
	}
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	if (isServer())
	{
		SpawnPlayer(victim);
	}
}

void onPlayerRequestTeamChange(CRules@ this, CPlayer@ player, u8 newTeam)
{
	u8 currentTeam = player.getTeamNum();
	if (currentTeam != newTeam)
	{
		player.server_setTeamNum(newTeam);
	}
}

void onPlayerChangedTeam(CRules@ this, CPlayer@ player, u8 oldTeam, u8 newTeam)
{
	if (oldTeam == newTeam || !Loading::isPlayerLoaded(player)) return;

	u8 spectatorTeam = this.getSpectatorTeamNum();

	if (newTeam == spectatorTeam)
	{
		Actor@ oldActor = Actor::getActor(player);
		Actor::RemoveActor(player);
		Actor::AddActor(SpectatorActor(oldActor.getPlayer(), oldActor.position));
	}
	else if (oldTeam == spectatorTeam)
	{
		Actor::RemoveActor(player);
		SpawnPlayer(player);
	}
}

void SpawnPlayer(CPlayer@ player)
{
	Actor::AddActor(SandboxActor(player, Vec3f(4, 2, 4)));
}
