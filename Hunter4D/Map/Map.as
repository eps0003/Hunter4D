#include "MapCommon.as"
#include "Blocks.as"
#include "MapRenderer.as"
#include "Vec3f.as"
#include "MapSyncer.as"

class Map
{
	private SColor[] blocks;
	Vec3f dimensions;
	uint blockCount = 0;

	Map(Vec3f dimensions)
	{
		this.dimensions = dimensions;
		blockCount = dimensions.x * dimensions.y * dimensions.z;
		blocks = array<SColor>(blockCount, 0);
	}

	void opAssign(Map map)
	{
		blocks = map.blocks;
		dimensions = map.dimensions;
		blockCount = map.blockCount;
	}

	void SetTemporaryBlock(Vec3f position, SColor block, CPlayer@ player)
	{
		SetTemporaryBlock(position.x, position.y, position.z, block, player);
	}

	void SetTemporaryBlock(int x, int y, int z, SColor block, CPlayer@ player)
	{
		SetTemporaryBlock(posToIndex(x, y, z), block, player);
	}

	void SetTemporaryBlock(int index, SColor block, CPlayer@ player)
	{
		SetBlockSafe(index, block);

		// Tell server to place block
		CBitStream bs;
		bs.write_netid(player.getNetworkID());
		bs.write_u32(index);
		bs.write_u32(block.color);
		getRules().SendCommand(getRules().getCommandID("place block"), bs, false);
	}

	void SetBlockSafe(Vec3f position, SColor block)
	{
		SetBlockSafe(position.x, position.y, position.z, block);
	}

	void SetBlockSafe(int x, int y, int z, SColor block)
	{
		if (isValidBlock(x, y, z))
		{
			SetBlock(x, y, z, block);
		}
	}

	void SetBlockSafe(int index, SColor block)
	{
		if (isValidBlock(index))
		{
			SetBlock(index, block);
		}
	}

	void SetBlock(Vec3f position, SColor block)
	{
		SetBlock(position.x, position.y, position.z, block);
	}

	void SetBlock(int x, int y, int z, SColor block)
	{
		SetBlock(posToIndex(x, y, z), block);
	}

	void SetBlock(int index, SColor block)
	{
		SColor oldBlock = blocks[index];
		blocks[index] = block;

		CRules@ rules = getRules();

		// Sync block to clients
		if (!isClient() && !rules.hasScript("GenerateMap.as") && !rules.hasScript("LoadMap.as"))
		{
			CBitStream bs;
			bs.write_u32(index);
			bs.write_u32(block.color);
			rules.SendCommand(rules.getCommandID("sync block"), bs, true);
		}

		if (isClient() && oldBlock != block && !rules.hasScript("SyncMap.as"))
		{
			Map::getRenderer().GenerateMesh(indexToPos(index));
		}
	}

	SColor getBlockSafe(Vec3f position)
	{
		return getBlockSafe(position.x, position.y, position.z);
	}

	SColor getBlockSafe(int x, int y, int z)
	{
		if (isValidBlock(x, y, z))
		{
			return getBlock(x, y, z);
		}
		return 0;
	}

	SColor getBlockSafe(int index)
	{
		if (isValidBlock(index))
		{
			return getBlock(index);
		}
		return 0;
	}

	SColor getBlock(Vec3f position)
	{
		return getBlock(position.x, position.y, position.z);
	}

	SColor getBlock(int x, int y, int z)
	{
		return getBlock(posToIndex(x, y, z));
	}

	SColor getBlock(int index)
	{
		return blocks[index];
	}

	bool isValidBlock(Vec3f position)
	{
		return isValidBlock(position.x, position.y, position.z);
	}

	bool isValidBlock(int x, int y, int z)
	{
		return (
			x >= 0 && x < dimensions.x &&
			y >= 0 && y < dimensions.y &&
			z >= 0 && z < dimensions.z
		);
	}

	bool isValidBlock(int index)
	{
		return index >= 0 && index < blockCount;
	}

	//https://coderwall.com/p/fzni3g/bidirectional-translation-between-1d-and-3d-arrays
	int posToIndex(Vec3f position)
	{
		return posToIndex(position.x, position.y, position.z);
	}

	int posToIndex(int x, int y, int z)
	{
		return x + (z * dimensions.x) + (y * dimensions.x * dimensions.z);
	}

	Vec3f indexToPos(int index)
	{
		Vec3f vec;
		vec.x = index % dimensions.x;
		vec.z = Maths::Floor(index / dimensions.x) % dimensions.z;
		vec.y = Maths::Floor(index / (dimensions.x * dimensions.z));
		return vec;
	}
}
