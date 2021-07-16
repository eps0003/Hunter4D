namespace Camera
{
	shared Camera@ getCamera()
	{
		Camera@ camera;
		if (!getRules().get("camera", @camera))
		{
			@camera = Camera();
			getRules().set("camera", @camera);
		}
		return camera;
	}
}
