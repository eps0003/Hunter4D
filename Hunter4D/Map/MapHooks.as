#include "Map.as"

void onInit(CRules@ this)
{
	this.addCommandID("sync block");
	this.addCommandID("sync map");
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	Map::getSyncer().AddRequest(player);
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (isClient())
	{
		if (cmd == this.getCommandID("sync block"))
		{
			uint index;
			if (!params.saferead_u32(index)) return;

			uint blockInt;
			if (!params.saferead_u32(blockInt)) return;
			SColor block(blockInt);

			Map@ map = Map::getMap();
			map.SetBlockSafe(index, block);
		}
		else if (cmd == this.getCommandID("sync map"))
		{
			CBitStream bs = params;
			bs.SetBitIndex(params.getBitIndex());
			Map::getSyncer().AddPacket(bs);
		}
	}
}
