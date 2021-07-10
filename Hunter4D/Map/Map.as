#include "MapCommon.as"
#include "Blocks.as"
#include "MapRenderer.as"
#include "Vec3f.as"
#include "MapSyncer.as"
#include "Object.as"
#include "Actor.as"

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

	void ClientSetBlockSafe(Vec3f position, SColor block)
	{
		ClientSetBlockSafe(position.x, position.y, position.z, block);
	}

	void ClientSetBlockSafe(int x, int y, int z, SColor block)
	{
		ClientSetBlockSafe(posToIndex(x, y, z), block);
	}

	void ClientSetBlockSafe(int index, SColor block)
	{
		CPlayer@ player = getLocalPlayer();

		if (canSetBlock(player, index, block))
		{
			SetBlockSafe(index, block);

			if (!isLocalHost())
			{
				// Tell server to place block
				CBitStream bs;
				bs.write_netid(player.getNetworkID());
				bs.write_u32(index);
				bs.write_u32(block.color);
				getRules().SendCommand(getRules().getCommandID("place block"), bs, false);
			}
		}
	}

	void SetBlockSafe(Vec3f position, SColor block, CPlayer@ player = null)
	{
		SetBlockSafe(position.x, position.y, position.z, block, player);
	}

	void SetBlockSafe(int x, int y, int z, SColor block, CPlayer@ player = null)
	{
		if (isValidBlock(x, y, z))
		{
			SetBlock(x, y, z, block, player);
		}
	}

	void SetBlockSafe(int index, SColor block, CPlayer@ player = null)
	{
		if (isValidBlock(index))
		{
			SetBlock(index, block, player);
		}
	}

	void SetBlock(Vec3f position, SColor block, CPlayer@ player = null)
	{
		SetBlock(position.x, position.y, position.z, block, player);
	}

	void SetBlock(int x, int y, int z, SColor block, CPlayer@ player = null)
	{
		SetBlock(posToIndex(x, y, z), block, player);
	}

	void SetBlock(int index, SColor block, CPlayer@ player = null)
	{
		SColor oldBlock = blocks[index];
		if (oldBlock == block) return;

		blocks[index] = block;

		CRules@ rules = getRules();

		// Sync block to clients
		if (!isClient() && !rules.hasScript("GenerateMap.as") && !rules.hasScript("LoadMap.as"))
		{
			CBitStream bs;
			bs.write_bool(player !is null);
			if (player !is null)
			{
				bs.write_netid(player.getNetworkID());
			}
			bs.write_u32(index);
			bs.write_u32(block.color);
			rules.SendCommand(rules.getCommandID("sync block"), bs, true);
		}

		if (isClient() && !rules.hasScript("SyncMap.as"))
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

	bool canSetBlock(CPlayer@ player, int index, SColor block)
	{
		if (Blocks::isSolid(block))
		{
			Vec3f position = indexToPos(index);

			// Prevent placing blocks inside objects
			Object@[]@ objects = Object::getObjects();
			for (uint i = 0; i < objects.size(); i++)
			{
				Object@ object = objects[i];

				if (object.hasCollider() &&
					object.hasCollisionFlags(CollisionFlag::Blocks) &&
					object.getCollider().intersectsVoxel(object.position, position))
				{
					return false;
				}
			}

			// Prevent placing blocks inside actors
			Actor@[]@ actors = Actor::getActors();
			for (uint i = 0; i < actors.size(); i++)
			{
				Actor@ actor = actors[i];

				if (actor.hasCollider() &&
					actor.hasCollisionFlags(CollisionFlag::Blocks) &&
					actor.getCollider().intersectsVoxel(actor.position, position))
				{
					return false;
				}
			}
		}

		return true;
	}
}
