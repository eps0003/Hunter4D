#include "Loading.as"

#define SERVER_ONLY

const uint WAIT_TIME = 20;
uint startTime = 0;

void onInit(CRules@ this)
{
	print("Waiting for players to begin the game...");
}

void onStateChange(CRules@ this, const u8 oldState)
{
	if (!this.isWarmup())
	{
		this.RemoveScript(getCurrentScriptName());
	}
}

void onTick(CRules@ this)
{
	if (Loading::getLoadedPlayerCount() < 2)
	{
		startTime = 0;
		return;
	}

	if (startTime == 0)
	{
		startTime = getGameTime() + getTicksASecond() * WAIT_TIME;
	}

	if (Loading::areAllPlayersLoaded() || getGameTime() >= startTime)
	{
		this.AddScript("Countdown.as");
		this.RemoveScript(getCurrentScriptName());
	}
}
