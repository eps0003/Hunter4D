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
		string[] skins = Skins::getDefaultSkins();
		if (skins.empty())
		{
			return "KnightSkin.png";
		}

		uint index = Maths::Abs(player.getUsername().getHash()) % skins.size();
		return skins[index];
	}

	shared void AddDefaultSkin(string file)
	{
		CRules@ rules = getRules();

		if (rules.exists("default skins"))
		{
			rules.push("default skins", file);
		}
		else
		{
			string[] skins = { file };
			rules.set("default skins", skins);
		}
	}

	shared string[] getDefaultSkins()
	{
		string[] skins;

		CRules@ rules = getRules();
		if (rules.exists("default skins"))
		{
			rules.get("default skins", skins);
		}

		return skins;
	}
}
