namespace Interpolation
{
	float getGameTime()
	{
		return getRules().get_f32("inter_game_time");
	}

	float getFrameTime()
	{
		return getRules().get_f32("inter_frame_time");
	}
}