namespace Maths
{
	shared s8 Sign(float value)
	{
		if (value > 0)
			return 1;
		if (value < 0)
			return -1;
		return 0;
	}

	shared float Clamp2(float value, float low, float high)
	{
		if (low > high)
		{
			float temp = low;
			low = high;
			high = temp;
		}

		return Maths::Clamp(value, low, high);
	}

	shared float AngleDifference(float a1, float a2)
	{
		float diff = (a2 - a1 + 180) % 360 - 180;
		return diff < -180 ? diff + 360 : diff;
	}

	shared float LerpAngle(float a1, float a2, float t)
	{
		return a1 + AngleDifference(a1, a2) * t;
	}

	shared float toRadians(float degrees)
	{
		return degrees * Maths::Pi / 180.0f;
	}

	shared float toDegrees(float radians)
	{
		return radians * 180.0f / Maths::Pi;
	}
}
