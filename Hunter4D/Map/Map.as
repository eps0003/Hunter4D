#include "MapCommon.as"
#include "MapRenderer.as"
#include "Vec3f.as"
#include "MapSyncer.as"
#include "Object.as"
#include "Actor.as"
#include "Particle.as"
#include "Loading.as"
#include "MapManager.as"

shared class Map
{
	private SColor[] blocks;
	private string[] usernames;
	Vec3f dimensions;
	uint blockCount = 0;

	private CRules@ rules = getRules();
	private ParticleManager@ particleManager;

	Map(Vec3f dimensions)
	{
		this.dimensions = dimensions;
		blockCount = dimensions.x * dimensions.y * dimensions.z;
		blocks = array<SColor>(blockCount, 0);

		if (isServer())
		{
			usernames = array<string>(blockCount);
		}

		if (isClient())
		{
			@particleManager = Particles::getManager();
		}
	}

	void opAssign(Map map)
	{
		blocks = map.blocks;
		usernames = map.usernames;
		dimensions = map.dimensions;
		blockCount = map.blockCount;
	}

	void ClientSetBlockSafe(Vec3f position, SColor block)
	{
		ClientSetBlockSafe(position.x, position.y, position.z, block);
	}

	void ClientSetBlockSafe(int x, int y, int z, SColor block)
	{
		if (isValidBlock(x, y, z))
		{
			ClientSetBlock(x, y, z, block);
		}
	}

	void ClientSetBlockSafe(int index, SColor block)
	{
		if (isValidBlock(index))
		{
			ClientSetBlock(index, block);
		}
	}

	void ClientSetBlock(Vec3f position, SColor block)
	{
		ClientSetBlock(position.x, position.y, position.z, block);
	}

	void ClientSetBlock(int x, int y, int z, SColor block)
	{
		ClientSetBlock(posToIndex(x, y, z), block);
	}

	void ClientSetBlock(int index, SColor block)
	{
		CPlayer@ player = getLocalPlayer();

		if (canSetBlock(player, index, block))
		{
			if (!isVisible(block))
			{
				Particles::EmitBlockBreakParticles(index, blocks[index]);
			}

			SetBlock(index, block);

			if (!isLocalHost())
			{
				// Tell server to place block
				CBitStream bs;
				bs.write_netid(player.getNetworkID());
				bs.write_u32(index);
				bs.write_u32(block.color);
				rules.SendCommand(rules.getCommandID("place block"), bs, false);
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

		// Sync block to clients
		if (!isClient() && !rules.hasScript("GenerateMap.as") && !rules.hasScript("LoadMap.as") && !rules.hasScript("LoadCfgMap.as"))
		{
			usernames[index] = player !is null ? player.getUsername() : "";

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

		if (isClient())
		{
			if (!rules.hasScript("SyncMap.as"))
			{
				Map::getRenderer().GenerateMesh(indexToPos(index));
			}

			if (!isVisible(block) && Loading::isMyPlayerLoaded())
			{
				ParticleManager@ particleManager = Particles::getManager();
				particleManager.CheckStaticParticles();
			}
		}
	}

	void SetHealth(int index, u8 health, CPlayer@ player = null)
	{
		if (health == 0)
		{
			SetBlock(index, 0, player);
			return;
		}

		blocks[index].setAlpha(health);

		// Sync health to clients
		if (!isClient())
		{
			CBitStream bs;
			bs.write_bool(player !is null);
			if (player !is null)
			{
				bs.write_netid(player.getNetworkID());
			}
			bs.write_u32(index);
			bs.write_u8(health);
			rules.SendCommand(rules.getCommandID("set block health"), bs, true);
		}

		if (isClient() && !rules.hasScript("SyncMap.as"))
		{
			Map::getRenderer().GenerateMesh(indexToPos(index));
		}
	}

	void DamageBlockSafe(Vec3f position, uint damage, CPlayer@ player = null)
	{
		DamageBlockSafe(position.x, position.y, position.z, damage, player);
	}

	void DamageBlockSafe(int x, int y, int z, uint damage, CPlayer@ player = null)
	{
		if (isValidBlock(x, y, z))
		{
			DamageBlock(x, y, z, damage, player);
		}
	}

	void DamageBlockSafe(int index, uint damage, CPlayer@ player = null)
	{
		if (isValidBlock(index))
		{
			DamageBlock(index, damage, player);
		}
	}

	void DamageBlock(Vec3f position, uint damage, CPlayer@ player = null)
	{
		DamageBlock(position.x, position.y, position.z, damage, player);
	}

	void DamageBlock(int x, int y, int z, uint damage, CPlayer@ player = null)
	{
		DamageBlock(posToIndex(x, y, z), damage, player);
	}

	void DamageBlock(int index, uint damage, CPlayer@ player = null)
	{
		u8 newHealth = Maths::Clamp(-damage + blocks[index].getAlpha(), 0, 255);
		SetHealth(index, newHealth);
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

	u8 getHealth(SColor block)
	{
		return block.getAlpha();
	}

	string getPlayerUsername(Vec3f position)
	{
		return getPlayerUsername(position.x, position.y, position.z);
	}

	string getPlayerUsername(int x, int y, int z)
	{
		return getPlayerUsername(posToIndex(x, y, z));
	}

	string getPlayerUsername(int index)
	{
		return usernames[index];
	}

	bool isValidBlock(Vec3f position)
	{
		return (
			position.x >= 0 && position.x < dimensions.x &&
			position.y >= 0 && position.y < dimensions.y &&
			position.z >= 0 && position.z < dimensions.z
		);
	}

	bool isValidBlock(int x, int y, int z)
	{
		return isValidBlock(Vec3f(x, y, z));
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
		if (isSolid(block))
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

	bool isVisible(SColor block)
	{
		return block.getAlpha() > 0;
	}

	bool isSolid(SColor block)
	{
		return isVisible(block);
	}

	bool isDestructible(SColor block)
	{
		return isVisible(block);
	}
}
