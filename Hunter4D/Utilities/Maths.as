namespace Maths
{
	s8 Sign(float value)
	{
		if (value > 0)
			return 1;
		if (value < 0)
			return -1;
		return 0;
	}

	float Clamp2(float value, float low, float high)
	{
		if (low > high)
		{
			float temp = low;
			low = high;
			high = temp;
		}

		return Maths::Clamp(value, low, high);
	}

	float AngleDifference(float a1, float a2)
	{
		float diff = (a2 - a1 + 180) % 360 - 180;
		return diff < -180 ? diff + 360 : diff;
	}

	float LerpAngle(float a1, float a2, float t)
	{
		return a1 + AngleDifference(a1, a2) * t;
	}

	float toRadians(float degrees)
	{
		return degrees * Maths::Pi / 180.0f;
	}

	float toDegrees(float radians)
	{
		return radians * 180.0f / Maths::Pi;
	}
}
