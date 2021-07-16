shared int getFPS()
{
	return getRules().get_u32("fps");
}

shared bool isTickPaused()
{
	return isLocalHost() && Menu::getMainMenu() !is null;
}

shared bool isLocalHost()
{
	return isClient() && isServer();
}
