#include "Interpolation.as"

shared class Stopwatch
{
	private uint startTime;
	private uint pauseTime;
	private uint extraTime;
	private bool running;
	private bool paused;

	Stopwatch()
	{
		Reset();
	}

	private void Reset()
	{
		startTime = 0;
		pauseTime = 0;
		extraTime = 0;
		running = false;
		paused = false;
	}

	void Start()
	{
		if (isPaused())
		{
			extraTime += getGameTime() - pauseTime;
			pauseTime = 0;
			paused = false;
		}
		else
		{
			startTime = getGameTime();
			running = true;
		}
	}

	void Pause()
	{
		pauseTime = getGameTime();
		paused = true;
	}

	void Stop()
	{
		Reset();
	}

	uint getStartTime()
	{
		return startTime;
	}

	float getTime()
	{
		if (isRunning() || isPaused())
		{
			return Interpolation::getGameTime() - startTime - getPauseDuration();
		}
		return 0;
	}

	private float getPauseDuration()
	{
		float time = extraTime;
		if (isPaused())
		{
			time += Interpolation::getGameTime() - pauseTime;
		}
		return time;
	}

	bool isPaused()
	{
		return paused;
	}

	bool isRunning()
	{
		return running && !isPaused();
	}

	string toString(bool showMilliseconds = false)
	{
		float totalSeconds = getTime() / getTicksASecond();
		uint hours = totalSeconds / 3600;
		totalSeconds %= 3600;
		u8 minutes = totalSeconds / 60;
		u8 seconds = totalSeconds % 60;
		totalSeconds %= 1;
		u16 milliseconds = totalSeconds * 1000;

		string text = hours + ":" + formatInt(minutes, "0", 2) + ":" + formatInt(seconds, "0", 2);
		if (showMilliseconds)
		{
			text += "." + formatInt(milliseconds, "0", 3);
		}

		return text;
	}
}
