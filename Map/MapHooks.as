#include "Map.as"

void onInit(CRules@ this)
{
	this.addCommandID("sync block");
	this.addCommandID("sync map");

	if (isServer())
	{
		Map@ map = Map::getMap();

		for (uint x = 0; x < map.dimensions.x; x++)
		for (uint z = 0; z < map.dimensions.z; z++)
		{
			map.SetBlock(x, 0, z, 1);
		}

		Map::getMapSyncer().AddRequestForEveryone();
	}
}

void onTick(CRules@ this)
{
	if (isServer())
	{
		Map::getMapSyncer().ServerSync();
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	Map::getMapSyncer().AddRequest(player);
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (isClient())
	{
		if (cmd == this.getCommandID("sync block"))
		{
			uint index = params.read_u32();
			u8 block = params.read_u8();

			Map@ map = Map::getMap();
			map.SetBlockSafe(index, block);
		}
		else if (cmd == this.getCommandID("sync map"))
		{
			CBitStream bs = params;
			bs.SetBitIndex(params.getBitIndex());
			Map::getMapSyncer().AddPacket(bs);
		}
	}
}
