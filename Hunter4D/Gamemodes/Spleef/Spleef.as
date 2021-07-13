#include "Loading.as"
#include "Map.as"
#include "SpleefActor.as"

#define SERVER_ONLY

Map@ map;

uint countdownDuration = 5 * getTicksASecond();
uint timeToStart;

void onInit(CRules@ this)
{
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
		u16 playerId;
		if (!params.saferead_netid(playerId)) return;

		CPlayer@ player = getPlayerByNetworkId(playerId);
		if (player is null) return;

		Vec3f spawnPos = map.dimensions * Vec3f(0.5f, 1.0f, 0.5f) + Vec3f(0, 2, 0);
		Actor::AddActor(SpleefActor(player, spawnPos));

		if (Loading::areAllPlayersLoaded())
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
	// Last player left
	if (getPlayerCount() == 1)
	{
		if (this.getCurrentState() == WARMUP)
		{
			timeToStart = 0;
		}
		else
		{
			LoadNextMap();
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
		Actor::RemoveActor(player);
	}
}
