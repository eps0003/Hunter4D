#define SERVER_ONLY

const uint COUNTDOWN_SECONDS = 5;
uint startTime = 0;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	print("Game starting in...");
	startTime = getGameTime() + getTicksASecond() * COUNTDOWN_SECONDS;
}

void onStateChange(CRules@ this, const u8 oldState)
{
	if (!this.isWarmup())
	{
		this.RemoveScript("Countdown.as");
	}
}

void onTick(CRules@ this)
{
	int deltaTime = startTime - getGameTime();

	if (deltaTime % getTicksASecond() == 0)
	{
		print("" + (deltaTime / getTicksASecond()));
	}

	if (deltaTime <= 0)
	{
		this.SetCurrentState(GAME);
		this.RemoveScript("Countdown.as");
	}
}
