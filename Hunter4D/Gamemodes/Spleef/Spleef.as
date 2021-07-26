#include "Loading.as"
#include "Map.as"
#include "SpleefActor.as"
#include "SpectatorActor.as"

#define SERVER_ONLY

Map@ map;

uint countdownDuration = 5 * getTicksASecond();
uint timeToStart;

void onInit(CRules@ this)
{
	Map::getManager().SetMap(ConfigMap("Ephtracy.cfg"));
	this.AddScript("ShortPostGame.as");
	onRestart(this);
}

void onRestart(CRules@ this)
{
	@map = Map::getMap();

	this.SetCurrentState(WARMUP);
	timeToStart = 0;
}

void onTick(CRules@ this)
{
	float gt = getGameTime();

	if (this.getCurrentState() == WARMUP && timeToStart > 0)
	{
		if (gt >= timeToStart)
		{
			this.SetCurrentState(GAME);
			print("Spleef!");
		}
		else
		{
			float time = timeToStart - gt;
			if (time % getTicksASecond() == 0)
			{
				print("Starting in "+(time / getTicksASecond()));
			}
		}
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("player loaded"))
	{
		CPlayer@ player;
		if (!saferead_player(params, @player)) return;

		SpawnPlayer(this, player);

		if (this.getCurrentState() == WARMUP && getPlayerCount() >= 2 && timeToStart == 0 && Loading::areAllPlayersLoaded())
		{
			timeToStart = getGameTime() + countdownDuration + 1;
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if (this.getCurrentState() == WARMUP)
	{
		player.server_setTeamNum(0);
	}
	else
	{
		player.server_setTeamNum(this.getSpectatorTeamNum());
	}
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	if (getPlayerCount() <= 1)
	{
		// No players left
		LoadNextMap();
	}
	else if (getPlayerCount() <= 2)
	{
		// One player left
		if (this.getCurrentState() == WARMUP)
		{
			timeToStart = 0;
		}
	}
}

void onPlayerRequestTeamChange(CRules@ this, CPlayer@ player, u8 newTeam)
{
	u8 currentTeam = player.getTeamNum();
	u8 spectatorTeam = this.getSpectatorTeamNum();

	bool differentTeam = currentTeam != newTeam;
	bool warmup = this.getCurrentState() == WARMUP;

	if (differentTeam && (warmup || newTeam == spectatorTeam))
	{
		player.server_setTeamNum(newTeam);
	}
}

void onPlayerChangedTeam(CRules@ this, CPlayer@ player, u8 oldTeam, u8 newTeam)
{
	if (oldTeam == newTeam || !Loading::isPlayerLoaded(player)) return;

	SpawnPlayer(this, player);
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	SpawnPlayer(this, victim);
}

void SpawnPlayer(CRules@ this, CPlayer@ player)
{
	Vec3f spawnPos = Vec3f(4, 2, 4);

	if (player.getTeamNum() == this.getSpectatorTeamNum() || this.getCurrentState() != WARMUP)
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
		Actor::AddActor(SpleefActor(player, spawnPos));
	}

	CheckWin(this);
}

void CheckWin(CRules@ this)
{
	if (this.getCurrentState() != GAME) return;

	SpleefActor@ winner;

	Actor@[]@ actors = Actor::getActors();
	for (uint i = 0; i < actors.size(); i++)
	{
		SpleefActor@ actor = cast<SpleefActor@>(actors[i]);
		if (actor !is null)
		{
			if (winner !is null) return;

			@winner = actor;
		}
	}

	if (winner is null) return;

	print(winner.getPlayer().getUsername() + " won");
	this.SetCurrentState(GAME_OVER);
}
