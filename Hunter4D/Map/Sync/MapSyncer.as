#include "MapRequest.as"
#include "Map.as"
#include "Utilities.as"

shared class MapSyncer
{
	private Map@ map = Map::getMap();
	private MapRequest@[] mapRequests;
	CBitStream@[] mapPackets;
	private uint blocksPerPacket = 20000;
	private bool synced = false;
	private u16 index = 0;

	private CRules@ rules = getRules();

	void AddRequest(CPlayer@ player, uint packet = 0)
	{
		MapRequest request(player, packet);
		mapRequests.push_back(request);
	}

	void AddRequestForEveryone()
	{
		mapRequests.clear();

		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player !is null)
			{
				AddRequest(player);
			}
		}
	}

	bool hasRequest(CPlayer@ player)
	{
		for (uint i = 0; i < mapRequests.size(); i++)
		{
			if (mapRequests[i].player is player)
			{
				return true;
			}
		}

		return false;
	}

	void AddPacket(CBitStream@ packet)
	{
		mapPackets.push_back(packet);
	}

	MapRequest@ getNextRequest()
	{
		MapRequest@ request;
		if (hasRequests())
		{
			@request = mapRequests[0];
			mapRequests.removeAt(0);
		}
		return request;
	}

	CBitStream@ getNextPacket()
	{
		CBitStream@ packet;
		if (hasPackets())
		{
			@packet = mapPackets[0];
			mapPackets.removeAt(0);
		}
		return packet;
	}

	int getCurrentIndex()
	{
		return index;
	}

	bool hasRequests()
	{
		return !mapRequests.empty();
	}

	bool hasPackets()
	{
		return !mapPackets.empty();
	}

	uint getTotalPackets()
	{
		return Maths::Ceil(map.blockCount / float(blocksPerPacket));
	}

	bool isSynced()
	{
		return synced || isLocalHost();
	}

	void ServerSync()
	{
		MapRequest@ request = getNextRequest();
		if (request is null) return;

		CPlayer@ player = request.player;
		index = request.packet;

		// Move straight onto next request if the player of this one doesn't exist
		if (player is null)
		{
			ServerSync();
			return;
		}

		// Get index of first and last block to sync
		uint firstBlock = index * blocksPerPacket;
		uint lastBlock = firstBlock + blocksPerPacket;

		// Serialize index
		CBitStream bs;
		bs.write_u16(index);

		// Serialize map size
		if (index == 0)
		{
			bs.write_u16(map.dimensions.x);
			bs.write_u16(map.dimensions.y);
			bs.write_u16(map.dimensions.z);
		}

		// Loop through these blocks and serialize
		for (uint i = firstBlock; i < lastBlock; i++)
		{
			if (i >= map.blockCount) break;

			SColor block = map.getBlock(i);

			bool visible = map.isVisible(block);
			bs.write_bool(visible);

			if (visible)
			{
				bs.write_u32(block.color);
			}
		}

		// Send to requesting player
		rules.SendCommand(rules.getCommandID("sync map"), bs, player);

		// Request next packet
		index++;
		if (index < getTotalPackets())
		{
			AddRequest(player, index);
		}
	}

	void ClientReceive()
	{
		CBitStream@ packet = getNextPacket();
		if (packet is null) return;

		if (!packet.saferead_u16(index)) return;

		uint firstBlock = index * blocksPerPacket;
		uint lastBlock = firstBlock + blocksPerPacket;

		if (index == 0)
		{
			u16 x, y, z;
			if (!packet.saferead_u16(x)) return;
			if (!packet.saferead_u16(y)) return;
			if (!packet.saferead_u16(z)) return;

			map = Map(Vec3f(x, y, z));
		}

		// Loop through these blocks and deserialize
		for (uint i = firstBlock; i < lastBlock; i++)
		{
			if (i >= map.blockCount) break;

			bool visible;
			if (!packet.saferead_bool(visible)) return;

			if (!visible) continue;

			uint block;
			if (!packet.saferead_u32(block)) return;

			map.SetBlock(i, block);
		}

		if (index == getTotalPackets() - 1)
		{
			synced = true;
		}
	}
}
