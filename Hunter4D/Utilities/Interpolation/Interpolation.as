namespace Interpolation
{
	shared float getGameTime()
	{
		return getRules().get_f32("inter_game_time");
	}

	shared float getFrameTime()
	{
		return getRules().get_f32("inter_frame_time");
	}
}
