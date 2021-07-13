#include "Map.as"

Map@ map;
MapSyncer@ mapSyncer;

void onInit(CRules@ this)
{
	this.addCommandID("sync block");
	this.addCommandID("place block");
	this.addCommandID("revert block");
	this.addCommandID("sync map");

	onRestart(this);
}

void onRestart(CRules@ this)
{
	@map = Map::getMap();
	@mapSyncer = Map::getSyncer();
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	mapSyncer.AddRequest(player);
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("sync block"))
	{
		bool hasPlayer;
		if (!params.saferead_bool(hasPlayer)) return;

		if (hasPlayer)
		{
			u16 playerId;
			if (!params.saferead_netid(playerId)) return;

			CPlayer@ player = getPlayerByNetworkId(playerId);
			if (player !is null && player.isMyPlayer()) return;
		}

		uint index;
		if (!params.saferead_u32(index)) return;
		if (!map.isValidBlock(index)) return;

		uint blockInt;
		if (!params.saferead_u32(blockInt)) return;
		SColor block(blockInt);

		if (!Blocks::isVisible(block))
		{
			Particles::EmitBlockBreakParticles(index, map.getBlock(index));
		}

		map.SetBlock(index, block);
	}
	else if (!isClient() && cmd == this.getCommandID("place block"))
	{
		u16 playerId;
		if (!params.saferead_netid(playerId)) return;

		CPlayer@ player = getPlayerByNetworkId(playerId);
		if (player is null) return;

		uint index;
		if (!params.saferead_u32(index)) return;
		if (!map.isValidBlock(index)) return;

		uint blockInt;
		if (!params.saferead_u32(blockInt)) return;
		SColor block(blockInt);

		if (map.canSetBlock(player, index, block))
		{
			map.SetBlock(index, block, player);
		}
		else
		{
			CBitStream bs;
			bs.write_u32(index);
			bs.write_u32(map.getBlock(index).color);
			this.SendCommand(this.getCommandID("revert block"), bs, player);
		}
	}
	else if (!isServer() && cmd == this.getCommandID("revert block"))
	{
		uint index;
		if (!params.saferead_u32(index)) return;

		uint blockInt;
		if (!params.saferead_u32(blockInt)) return;
		SColor block(blockInt);

		map.SetBlockSafe(index, block);
	}
	else if (!isServer() && cmd == this.getCommandID("sync map"))
	{
		CBitStream bs = params;
		bs.SetBitIndex(params.getBitIndex());
		mapSyncer.AddPacket(bs);
	}
}
