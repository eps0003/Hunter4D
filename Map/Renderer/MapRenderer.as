#include "Map.as"
#include "Chunk.as"
#include "FaceFlags.as"

class MapRenderer
{
	Map@ map;
	private Blocks@ blocks;

	Chunk@[] chunks;
	u8[] faceFlags;

	u8 chunkDimension = 8;
	Vec3f chunkDimensions;
	uint chunkCount = 0;

	string texture = "BlocksMC.png";
	SMaterial@ material = SMaterial();

	MapRenderer()
	{
		InitMaterial();

		@map = Map::getMap();
		@blocks = Blocks::getBlocks();

		chunkDimensions = (map.dimensions / chunkDimension).ceil();

		faceFlags.set_length(map.blocks.size());

		Vec3f chunkCountVec = (map.dimensions / chunkDimension).ceil();
		chunkCount = chunkCountVec.x * chunkCountVec.y * chunkCountVec.z;
		chunks.set_length(chunkCount);
	}

	private void InitMaterial()
	{
		material.AddTexture(texture);
		material.SetFlag(SMaterial::LIGHTING, false);
		material.SetFlag(SMaterial::BILINEAR_FILTER, false);
		material.SetFlag(SMaterial::FOG_ENABLE, true);
		material.SetMaterialType(SMaterial::TRANSPARENT_ALPHA_CHANNEL_REF);
	}

	void GenerateMesh(Vec3f position)
	{
		Vec3f chunkPos = worldPosToChunkPos(position);
		Chunk@ chunk = getChunk(chunkPos);
		if (chunk !is null)
		{
			chunk.rebuild = true;
		}
	}

	bool isValidChunk(int index)
	{
		return index >= 0 && index < chunks.size();
	}

	void Render()
	{
		material.SetVideoMaterial();

		bool synced = Map::getSyncer().isSynced();

		for (uint i = 0; i < chunks.size(); i++)
		{
			Chunk@ chunk = chunks[i];

			if (synced && chunk.rebuild)
			{
				chunk.GenerateMesh(i);

				Vec3f pos = chunkIndexToPos(i);
				print("Rebuild chunk mesh: " + pos.toString());
			}

			chunk.Render();
		}
	}

	void UpdateBlockFaces(int index)
	{
		Vec3f pos = map.indexToPos(index);
		UpdateBlockFaces(index, pos.x, pos.y, pos.z);
	}

	void UpdateBlockFaces(int x, int y, int z)
	{
		int index = map.posToIndex(x, y, z);
		UpdateBlockFaces(index, x, y, z);
	}

	private void UpdateBlockFaces(int index, int x, int y, int z)
	{
		u8 faces = FaceFlag::None;

		if (blocks.isVisible(map.getBlock(index)))
		{
			if (x == 0 || blocks.isTransparent(map.getBlock(x - 1, y, z)))
			{
				faces |= FaceFlag::Left;
			}

			if (x == map.dimensions.x - 1 || blocks.isTransparent(map.getBlock(x + 1, y, z)))
			{
				faces |= FaceFlag::Right;
			}

			if (y == 0 || blocks.isTransparent(map.getBlock(x, y - 1, z)))
			{
				faces |= FaceFlag::Down;
			}

			if (y == map.dimensions.y - 1 || blocks.isTransparent(map.getBlock(x, y + 1, z)))
			{
				faces |= FaceFlag::Up;
			}

			if (z == 0 || blocks.isTransparent(map.getBlock(x, y, z - 1)))
			{
				faces |= FaceFlag::Front;
			}

			if (z == map.dimensions.z - 1 || blocks.isTransparent(map.getBlock(x, y, z + 1)))
			{
				faces |= FaceFlag::Back;
			}
		}

		faceFlags[index] = faces;
	}

	Chunk@ getChunk(Vec3f position)
	{
		return getChunk(chunkPosToChunkIndex(position));
	}

	Chunk@ getChunk(int index)
	{
		if (isValidChunk(index))
		{
			return chunks[index];
		}
		return null;
	}

	Vec3f worldPosToChunkPos(Vec3f position)
	{
		return position / chunkDimension;
	}

	Vec3f worldPosToChunkPos(float x, float y, float z)
	{
		return worldPosToChunkPos(Vec3f(x, y, z));
	}

	int chunkPosToChunkIndex(Vec3f position)
	{
		return chunkPosToChunkIndex(position.x, position.y, position.z);
	}

	int chunkPosToChunkIndex(int x, int y, int z)
	{
		return x + (z * chunkDimensions.x) + (y * chunkDimensions.x * chunkDimensions.z);
	}

	Vec3f chunkIndexToPos(int index)
	{
		Vec3f vec;
		vec.x = index % chunkDimensions.x;
		vec.z = Maths::Floor(index / chunkDimensions.x) % chunkDimensions.z;
		vec.y = Maths::Floor(index / (chunkDimensions.x * chunkDimensions.z));
		return vec;
	}
}
