namespace Skins
{
	shared string getSkinName(CPlayer@ player)
	{
		return Skins::hasCustomSkin(player) ? player.getNetworkID() + "skin" : Skins::getDefaultSkinName(player);
	}

	shared bool hasCustomSkin(CPlayer@ player)
	{
		return Texture::exists(player.getNetworkID() + "skin");
	}

	shared string getDefaultSkinName(CPlayer@ player)
	{
		return "KnightSkin.png";
	}
}
