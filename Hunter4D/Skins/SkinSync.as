#include "Skins.as"
#include "Utilities.as"

const uint SPRITE_WIDTH = 64;
const uint SPRITE_HEIGHT = 64;
const string SKIN_PATH = "Maps/skin.png";

bool clientSynced = false;

void onInit(CRules@ this)
{
	this.addCommandID("sync skin");
}

void onTick(CRules@ this)
{
	if (!isClient() || clientSynced) return;

	CPlayer@ player = getLocalPlayer();
	if (player is null) return;

	string name = player.getNetworkID() + "skin";
	if (CFileMatcher(SKIN_PATH).getFirst() == SKIN_PATH && Texture::createFromFile(name, SKIN_PATH))
	{
		ImageData@ data = Texture::data(name);

		if (data.width() == SPRITE_WIDTH && data.height() == SPRITE_HEIGHT)
		{
			PreventInvisibleSkin(name, data);

			if (!isServer())
			{
				CBitStream bs;
				bs.write_netid(player.getNetworkID());
				Serialize(data, bs);
				this.SendCommand(this.getCommandID("sync skin"), bs, true);
			}

			print("Skin loaded!");
		}
		else
		{
			Texture::destroy(name);
			warn("Invalid skin sprite size");
		}
	}
	else
	{
		print("Skin does not exist");
	}

	clientSynced = true;
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("sync skin"))
	{
		CPlayer@ player;
		if (!saferead_player(params, @player)) return;

		if (player.isMyPlayer()) return;

		ImageData@ data;
		if (!deserialize(params, @data)) return;

		Texture::createFromData(player.getNetworkID() + "skin", data);
		print("Synced skin: " + player.getUsername());
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if (!isServer()) return;

	for (uint i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player2 = getPlayer(i);
		if (player2 !is null)
		{
			ImageData@ data = Texture::data(player2.getNetworkID() + "skin");
			if (data !is null)
			{
				CBitStream bs;
				bs.write_netid(player2.getNetworkID());
				Serialize(data, bs);
				this.SendCommand(this.getCommandID("sync skin"), bs, player);
			}
		}
	}
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	Texture::destroy(player.getNetworkID() + "skin");
}

void PreventInvisibleSkin(string name, ImageData@ data)
{
	CFileImage mask("SkinMask.png");

	for (uint x = 0; x < SPRITE_WIDTH; x++)
	for (uint y = 0; y < SPRITE_HEIGHT; y++)
	{
		SColor pixel = data.get(x, y);

		if (pixel.getAlpha() == 0)
		{
			mask.setPixelPosition(Vec2f(x, y));
			SColor maskPixel = mask.readPixel();

			if (maskPixel.getAlpha() > 0)
			{
				data.put(x, y, color_black.color);
			}
			else
			{
				data.put(x, y, 0);
			}
		}
	}

	Texture::update(name, data);
}

void Serialize(ImageData@ data, CBitStream@ bs)
{
	for (uint i = 0; i < data.size(); i++)
	{
		bs.write_u32(data[i].color);
	}
}

bool deserialize(CBitStream@ bs, ImageData@ &out data)
{
	@data = ImageData(SPRITE_WIDTH, SPRITE_HEIGHT);

	for (uint y = 0; y < SPRITE_HEIGHT; y++)
	for (uint x = 0; x < SPRITE_WIDTH; x++)
	{
		uint color;
		if (!bs.saferead_u32(color)) return false;

		data.put(x, y, color);
	}

	return true;
}
