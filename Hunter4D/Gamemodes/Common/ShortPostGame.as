#define SERVER_ONLY

const uint POST_GAME_SECONDS = 5;
uint endTime = 0;

void onStateChange(CRules@ this, const u8 oldState)
{
	if (this.isGameOver())
	{
		endTime = getGameTime() + getTicksASecond() * POST_GAME_SECONDS;
	}
	else
	{
		endTime = 0;
	}
}

void onTick(CRules@ this)
{
	if (endTime > 0 && getGameTime() >= endTime)
	{
		this.RemoveScript("ShortPostGame.as");
		LoadNextMap();
	}
}
