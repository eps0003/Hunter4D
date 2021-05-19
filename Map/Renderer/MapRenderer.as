#include "MapRendererCommon.as"
#include "Map.as"
#include "Chunk.as"
#include "FaceFlags.as"

class MapRenderer
{
	Chunk@[] chunks;
	u8[] faceFlags;
	u8 chunkDimension = 8;

	string texture = "BlocksMC.png";
	SMaterial@ material = SMaterial();

	MapRenderer()
	{
		InitMaterial();
		faceFlags.set_length(Map::getMap().blocks.size());

		Map@ map = Map::getMap();
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

	void GenerateMesh(Map@ map)
	{
		for (uint i = 0; i < chunks.size(); i++)
		{
			chunks[i].GenerateMesh(map, i);
		}
	}

	void Render()
	{
		material.SetVideoMaterial();

		for (uint i = 0; i < chunks.size(); i++)
		{
			chunks[i].Render();
		}
	}

	void UpdateBlockFaces(Map@ map, int x, int y, int z)
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
}
