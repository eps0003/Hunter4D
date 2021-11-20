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
		return formatDuration(getTime(), showMilliseconds);
	}
}
