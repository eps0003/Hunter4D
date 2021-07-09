#include "Map.as"

void onInit(CRules@ this)
{
	this.addCommandID("sync block");
	this.addCommandID("place block");
	this.addCommandID("place block fail");
	this.addCommandID("sync map");
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	Map::getSyncer().AddRequest(player);
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("sync block"))
	{
		uint index;
		if (!params.saferead_u32(index)) return;

		uint blockInt;
		if (!params.saferead_u32(blockInt)) return;
		SColor block(blockInt);

		Map@ map = Map::getMap();
		if (map.isValidBlock(index) && map.getBlock(index) == block)
		{
			map.SetBlock(index, block);
		}
	}
	else if (isServer() && cmd == this.getCommandID("place block"))
	{
		u16 playerId;
		if (!params.saferead_netid(playerId)) return;

		CPlayer@ player = getPlayerByNetworkId(playerId);
		if (player is null) return;

		uint index;
		if (!params.saferead_u32(index)) return;

		uint blockInt;
		if (!params.saferead_u32(blockInt)) return;
		SColor block(blockInt);

		Map@ map = Map::getMap();
		if (map.isValidBlock(index))
		{
			if (true) // if (canPlaceBlock(index, player))
			{
				map.SetBlock(index, block);
			}
			else
			{
				CBitStream bs;
				bs.write_u32(index);
				bs.write_u32(map.getBlock(index).color);
				this.SendCommand(this.getCommandID("place block fail"), bs, player);
			}
		}
	}
	else if (isClient() && cmd == this.getCommandID("place block fail"))
	{
		uint index;
		if (!params.saferead_u32(index)) return;

		uint blockInt;
		if (!params.saferead_u32(blockInt)) return;
		SColor block(blockInt);

		Map::getMap().SetBlockSafe(index, block);
	}
	else if (!isServer() && cmd == this.getCommandID("sync map"))
	{
		CBitStream bs = params;
		bs.SetBitIndex(params.getBitIndex());
		Map::getSyncer().AddPacket(bs);
	}
}
