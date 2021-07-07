int getFPS()
{
	return getRules().get_u32("fps");
}

bool isTickPaused()
{
	return isLocalHost() && Menu::getMainMenu() !is null;
}

bool isLocalHost()
{
	return isClient() && isServer();
}
