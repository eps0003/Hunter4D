#include "MapCommon.as"
#include "Block.as"
#include "MapRenderer.as"
#include "Vec3f.as"
#include "MapSyncer.as"

class Map
{
	u8[] blocks;
	Vec3f dimensions;
	uint blockCount = 0;

	Map() {}

	Map(Vec3f dimensions)
	{
		this.dimensions = dimensions;
		blockCount = dimensions.x * dimensions.y * dimensions.z;
		blocks.set_length(blockCount);
	}

	void opAssign(Map map)
	{
		blocks = map.blocks;
		dimensions = map.dimensions;
		blockCount = map.blockCount;
	}

	void SetBlockSafe(Vec3f position, u8 block)
	{
		SetBlockSafe(position.x, position.y, position.z, block);
	}

	void SetBlockSafe(int x, int y, int z, u8 block)
	{
		if (isValidBlock(x, y, z))
		{
			SetBlock(x, y, z, block);
		}
	}

	void SetBlockSafe(int index, u8 block)
	{
		if (isValidBlock(index))
		{
			SetBlock(index, block);
		}
	}

	void SetBlock(Vec3f position, u8 block)
	{
		SetBlock(position.x, position.y, position.z, block);
	}

	void SetBlock(int x, int y, int z, u8 block)
	{
		SetBlock(posToIndex(x, y, z), block);
	}

	void SetBlock(int index, u8 block)
	{
		blocks[index] = block;

		// Sync block to clients
		if (!isClient() && !getRules().hasScript("GenerateMap.as"))
		{
			CBitStream bs;
			bs.write_u32(index);
			bs.write_u8(block);
			getRules().SendCommand(getRules().getCommandID("sync block"), bs, true);
		}

		if (isClient() && !getRules().hasScript("SyncMap.as"))
		{
			Map::getRenderer().GenerateMesh(indexToPos(index));
		}
	}

	u8 getBlockSafe(Vec3f position)
	{
		return getBlockSafe(position.x, position.y, position.z);
	}

	u8 getBlockSafe(int x, int y, int z)
	{
		if (isValidBlock(x, y, z))
		{
			return getBlock(x, y, z);
		}
		return 0;
	}

	u8 getBlockSafe(int index)
	{
		if (isValidBlock(index))
		{
			return getBlock(index);
		}
		return 0;
	}

	u8 getBlock(Vec3f position)
	{
		return getBlock(position.x, position.y, position.z);
	}

	u8 getBlock(int x, int y, int z)
	{
		return getBlock(posToIndex(x, y, z));
	}

	u8 getBlock(int index)
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
		return index >= 0 && index < blocks.size();
	}

	//https://coderwall.com/p/fzni3g/bidirectional-translation-between-1d-and-3d-arrays
	int posToIndex(Vec3f position)
	{
		return posToIndex(position.x, position.y, position.z);
	}

	int posToIndex(int x, int y, int z)
	{
		return x + (y * dimensions.x) + (z * dimensions.z * dimensions.y);
	}

	Vec3f indexToPos(int index)
	{
		Vec3f vec;
		vec.x = index % dimensions.x;
		vec.y = Maths::Floor(index / dimensions.x) % dimensions.y;
		vec.z = Maths::Floor(index / (dimensions.x * dimensions.y));
		return vec;
	}
}
