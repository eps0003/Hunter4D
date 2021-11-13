#include "SquidGamer.as"
#include "SpectatorActor.as"
#include "Loading.as"
#include "Map.as"
#include "Doll.as"

MapManager@ mapManager;

void onInit(CRules@ this)
{
	if (isServer())
	{
		@mapManager = Map::getManager();
		mapManager.SetMap(ConfigMap("Ephtracy.cfg"));
	}

	if (isClient())
	{
		Skins::AddDefaultSkin("GiHun.png");
		Skins::AddDefaultSkin("SaeByeok.png");
	}

	onRestart(this);
}

void onRestart(CRules@ this)
{
	if (isServer())
	{
		this.SetCurrentState(GAME);
		Object::AddObject(Doll(Vec3f(4, 3, 4)));
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (isServer() && cmd == this.getCommandID("player loaded"))
	{
		CPlayer@ player;
		if (!saferead_player(params, @player)) return;

		SpawnPlayer(this, player);
	}
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	victim.server_setTeamNum(this.getSpectatorTeamNum());
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
	Vec3f spawnPos = Vec3f(4, 3, 4);

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
		Actor::AddActor(SquidGamer(player, spawnPos));
	}
}
