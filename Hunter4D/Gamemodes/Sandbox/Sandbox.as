#include "SandboxActor.as"
#include "SpectatorActor.as"
#include "Loading.as"
#include "Map.as"

#define SERVER_ONLY

MapManager@ mapManager;

void onInit(CRules@ this)
{
	@mapManager = Map::getManager();
	mapManager.SetMap(ConfigMap("Ephtracy.cfg"));

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
		CPlayer@ player;
		if (!saferead_player(params, @player)) return;

		SpawnPlayer(this, player);
	}
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	SpawnPlayer(this, victim);
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

	// Swapping between teams (not spectator) doesn't respawn the player
	if (oldTeam != this.getSpectatorTeamNum() && newTeam != this.getSpectatorTeamNum()) return;

	SpawnPlayer(this, player);
}

void SpawnPlayer(CRules@ this, CPlayer@ player)
{
	Vec3f spawnPos = Vec3f(4, 2, 4);

	if (player.getTeamNum() == this.getSpectatorTeamNum())
	{
		Actor@ oldActor = Actor::getActor(player);
		if (oldActor !is null)
		{
			Actor::AddActor(SpectatorActor(oldActor));
		}
		else
		{
			Actor::AddActor(SpectatorActor(player, spawnPos));
		}
	}
	else
	{
		Actor::AddActor(SandboxActor(player, spawnPos));
	}
}
