#include "MapRendererCommon.as"
#include "Map.as"
#include "Chunk.as"
#include "FaceFlags.as"

class MapRenderer
{
	Map@ map;

	Chunk@[] chunks;
	u8[] faceFlags;

	u8 chunkDimension = 8;
	Vec3f chunkDimensions;

	string texture = "BlocksMC.png";
	SMaterial@ material = SMaterial();

	MapRenderer()
	{
		InitMaterial();

		@map = Map::getMap();

		chunkDimensions = (map.dimensions / chunkDimension).ceil();

		faceFlags.set_length(map.blocks.size());

		Vec3f chunkCount = (map.dimensions / chunkDimension).ceil();
		chunks.set_length(chunkCount.x * chunkCount.y * chunkCount.z);

		for (uint i = 0; i < chunks.size(); i++)
		{
			@chunks[i] = Chunk(this, i);
		}
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

		bool synced = Map::getMapSyncer().synced;

		for (uint i = 0; i < chunks.size(); i++)
		{
			Chunk@ chunk = chunks[i];

			if (synced && chunk.rebuild)
			{
				chunk.GenerateMesh(map, i);

				Vec3f pos = chunkIndexToPos(i);
				print("Rebuild chunk mesh: " + pos.toString());
			}

			chunk.Render();
		}
	}

	void UpdateBlockFaces(int x, int y, int z)
	{
		int index = map.posToIndex(x, y, z);
		u8 block = map.getBlock(index);
		Block@ blockType = Block::getBlock(block);

		u8 faces = FaceFlag::None;

		if (blockType.visible)
		{
			{
				block = map.getBlock(x - 1, y, z);
				@blockType = Block::getBlock(block);

				if (x == 0 || blockType.transparent)
				{
					faces |= FaceFlag::Left;
				}
			}
			{
				block = map.getBlock(x + 1, y, z);
				@blockType = Block::getBlock(block);

				if (x == map.dimensions.x - 1 || blockType.transparent)
				{
					faces |= FaceFlag::Right;
				}
			}
			{
				block = map.getBlock(x, y - 1, z);
				@blockType = Block::getBlock(block);

				if (y == 0 || blockType.transparent)
				{
					faces |= FaceFlag::Down;
				}
			}
			{
				block = map.getBlock(x, y + 1, z);
				@blockType = Block::getBlock(block);

				if (y == map.dimensions.y - 1 || blockType.transparent)
				{
					faces |= FaceFlag::Up;
				}
			}
			{
				block = map.getBlock(x, y, z - 1);
				@blockType = Block::getBlock(block);

				if (z == 0 || blockType.transparent)
				{
					faces |= FaceFlag::Front;
				}
			}
			{
				block = map.getBlock(x, y, z + 1);
				@blockType = Block::getBlock(block);

				if (z == map.dimensions.z - 1 || blockType.transparent)
				{
					faces |= FaceFlag::Back;
				}
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
		return x + (y * chunkDimensions.x) + (z * chunkDimensions.z * chunkDimensions.y);
	}

	Vec3f chunkIndexToPos(int index)
	{
		Vec3f vec;
		vec.x = index % chunkDimensions.x;
		vec.y = Maths::Floor(index / chunkDimensions.x) % chunkDimensions.y;
		vec.z = Maths::Floor(index / (chunkDimensions.x * chunkDimensions.y));
		return vec;
	}
}
