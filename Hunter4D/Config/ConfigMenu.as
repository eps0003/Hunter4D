void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
	CContextMenu@ configMenu = Menu::addContextMenu(menu, getTranslatedString("Hunter3D Commands"));
	Menu::addInfoBox(configMenu, getTranslatedString("!sensitivity"), getTranslatedString("Change mouse sensitivity.\nDefault: 1.0"));
	Menu::addInfoBox(configMenu, getTranslatedString("!fov"), getTranslatedString("Change camera field of view.\nDefault: 70.0"));
	Menu::addInfoBox(configMenu, getTranslatedString("!distance"), getTranslatedString("Change render distance.\nDefault: 150.0"));
}
