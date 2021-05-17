#include "Map.as"

uint index = 0;

void onInit(CRules@ this)
{
	this.addCommandID("click");
}

void onTick(CRules@ this)
{
	if (isClient() && getControls().isKeyJustPressed(KEY_LBUTTON))
	{
		if (isServer())
		{
			PlaceBlock();
		}
		else
		{
			CBitStream bs;
			bs.write_netid(getLocalPlayer().getNetworkID());
			this.SendCommand(this.getCommandID("click"), bs, false);
		}
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (isServer() && cmd == this.getCommandID("click"))
	{
		PlaceBlock();
	}
}

void PlaceBlock()
{
	Map@ map = Map::getMap();
	map.SetBlock(index++, 1);
}
