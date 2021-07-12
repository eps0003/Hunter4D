namespace Loading
{
	Loading@ getLoading()
	{
		Loading@ loading;
		if (!getRules().get("loading", @loading))
		{
			@loading = Loading();
			getRules().set("loading", @loading);
		}
		return loading;
	}
}
