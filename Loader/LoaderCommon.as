namespace Loader
{
	Loader@ getLoader()
	{
		Loader@ loader;
		if (!getRules().get("loader", @loader))
		{
			@loader = Loader();
			getRules().set("loader", @loader);
		}
		return loader;
	}
}
