#include "Map.as"
#include "Chunk.as"
#include "FaceFlags.as"
#include "Camera.as"
#include "Tree.as"

shared class MapRenderer
{
	CRules@ rules = getRules();
	Map@ map = Map::getMap();
	private Camera@ camera = Camera::getCamera();

	private Chunk@[] chunks;
	private u8[] faceFlags;

	Tree@ tree;

	u8 chunkDimension = 16;
	Vec3f chunkDimensions;
	uint chunkCount = 0;
	uint visibleChunkCount = 0;

	string texture = "pixel";
	SMaterial@ material = SMaterial();

	private float shadeIntensity = 0.07f;
	private u8[] shadeScale = { 2, 3, 5, 0, 1, 4 };

	private SMesh xrayMesh;

	MapRenderer()
	{
		InitMaterial();

		faceFlags.set_length(map.blockCount);

		chunkDimensions = (map.dimensions / chunkDimension).ceil();
		chunkCount = chunkDimensions.x * chunkDimensions.y * chunkDimensions.z;
		chunks.set_length(chunkCount);

		xrayMesh.SetHardwareMapping(SMesh::DYNAMIC);
	}

	private void InitMaterial()
	{
		material.AddTexture(texture);
		material.SetFlag(SMaterial::LIGHTING, false);
		material.SetFlag(SMaterial::BILINEAR_FILTER, false);
		material.SetFlag(SMaterial::FOG_ENABLE, true);
		material.SetMaterialType(SMaterial::TRANSPARENT_ALPHA_CHANNEL_REF);
	}

	void GenerateMesh(int index)
	{
		Vec3f pos = map.indexToPos(index);
		GenerateMesh(index, pos);
	}

	void GenerateMesh(Vec3f position)
	{
		int index = map.posToIndex(position);
		GenerateMesh(index, position);
	}

	void GenerateMesh(int index, Vec3f position)
	{
		Vec3f chunkPos = worldPosToChunkPos(position);
		Chunk@ chunk = getChunkSafe(chunkPos);
		if (chunk !is null)
		{
			chunk.rebuild = true;

			int x = position.x;
			int y = position.y;
			int z = position.z;

			int cx = chunkPos.x;
			int cy = chunkPos.y;
			int cz = chunkPos.z;

			int xMod = x % chunkDimension;
			int yMod = y % chunkDimension;
			int zMod = z % chunkDimension;

			UpdateBlockFaces(index, x, y, z);

			bool visible = map.isVisible(map.getBlock(index));

			if (x > 0)
			{
				index = map.posToIndex(x - 1, y, z);
				if (visible)
					faceFlags[index] &= ~FaceFlag::Right;
				else if (map.isVisible(map.getBlock(index)))
					faceFlags[index] |= FaceFlag::Right;
			}

			if (x + 1 < map.dimensions.x)
			{
				index = map.posToIndex(x + 1, y, z);
				if (visible)
					faceFlags[index] &= ~FaceFlag::Left;
				else if (map.isVisible(map.getBlock(index)))
					faceFlags[index] |= FaceFlag::Left;
			}

			if (z > 0)
			{
				index = map.posToIndex(x, y, z - 1);
				if (visible)
					faceFlags[index] &= ~FaceFlag::Back;
				else if (map.isVisible(map.getBlock(index)))
					faceFlags[index] |= FaceFlag::Back;
			}

			if (z + 1 < map.dimensions.z)
			{
				index = map.posToIndex(x, y, z + 1);
				if (visible)
					faceFlags[index] &= ~FaceFlag::Front;
				else if (map.isVisible(map.getBlock(index)))
					faceFlags[index] |= FaceFlag::Front;
			}

			if (y > 0)
			{
				index = map.posToIndex(x, y - 1, z);
				if (visible)
					faceFlags[index] &= ~FaceFlag::Up;
				else if (map.isVisible(map.getBlock(index)))
					faceFlags[index] |= FaceFlag::Up;
			}

			if (y + 1 < map.dimensions.y)
			{
				index = map.posToIndex(x, y + 1, z);
				if (visible)
					faceFlags[index] &= ~FaceFlag::Down;
				else if (map.isVisible(map.getBlock(index)))
					faceFlags[index] |= FaceFlag::Down;
			}

			if (xMod == 0)
			{
				@chunk = getChunkSafe(cx - 1, cy, cz);
				if (chunk !is null) chunk.rebuild = true;
			}

			if (xMod == chunkDimension - 1)
			{
				@chunk = getChunkSafe(cx + 1, cy, cz);
				if (chunk !is null) chunk.rebuild = true;
			}

			if (yMod == 0)
			{
				@chunk = getChunkSafe(cx, cy - 1, cz);
				if (chunk !is null) chunk.rebuild = true;
			}

			if (yMod == chunkDimension - 1)
			{
				@chunk = getChunkSafe(cx, cy + 1, cz);
				if (chunk !is null) chunk.rebuild = true;
			}

			if (zMod == 0)
			{
				@chunk = getChunkSafe(cx, cy, cz - 1);
				if (chunk !is null) chunk.rebuild = true;
			}

			if (zMod == chunkDimension - 1)
			{
				@chunk = getChunkSafe(cx, cy, cz + 1);
				if (chunk !is null) chunk.rebuild = true;
			}
		}
	}

	bool isValidChunk(Vec3f position)
	{
		return (
			position.x >= 0 && position.x < chunkDimensions.x &&
			position.y >= 0 && position.y < chunkDimensions.y &&
			position.z >= 0 && position.z < chunkDimensions.z
		);
	}

	bool isValidChunk(int x, int y, int z)
	{
		return (
			x >= 0 && x < chunkDimensions.x &&
			y >= 0 && y < chunkDimensions.y &&
			z >= 0 && z < chunkDimensions.z
		);
	}

	bool isValidChunk(int index)
	{
		return index >= 0 && index < chunks.size();
	}

	void Render()
	{
		material.SetVideoMaterial();
		visibleChunkCount = tree.RenderVisibleChunks();

		if (getLocalPlayer().getTeamNum() != rules.getSpectatorTeamNum())
		{
			PreventXray();
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

	void UpdateBlockFaces(int index, int x, int y, int z)
	{
		u8 faces = FaceFlag::None;

		if (map.isVisible(map.getBlock(index)))
		{
			if (x == 0 || !map.isVisible(map.getBlock(x - 1, y, z)))
			{
				faces |= FaceFlag::Left;
			}

			if (x == map.dimensions.x - 1 || !map.isVisible(map.getBlock(x + 1, y, z)))
			{
				faces |= FaceFlag::Right;
			}

			if (y == 0 || !map.isVisible(map.getBlock(x, y - 1, z)))
			{
				faces |= FaceFlag::Down;
			}

			if (y == map.dimensions.y - 1 || !map.isVisible(map.getBlock(x, y + 1, z)))
			{
				faces |= FaceFlag::Up;
			}

			if (z == 0 || !map.isVisible(map.getBlock(x, y, z - 1)))
			{
				faces |= FaceFlag::Front;
			}

			if (z == map.dimensions.z - 1 || !map.isVisible(map.getBlock(x, y, z + 1)))
			{
				faces |= FaceFlag::Back;
			}
		}

		faceFlags[index] = faces;
	}

	void SetChunk(int index, Chunk@ chunk)
	{
		@chunks[index] = chunk;
	}

	Chunk@ getChunkSafe(Vec3f position)
	{
		if (isValidChunk(position))
		{
			return getChunk(position.x, position.y, position.z);
		}
		return null;
	}

	Chunk@ getChunkSafe(int x, int y, int z)
	{
		if (isValidChunk(x, y, z))
		{
			return getChunk(x, y, z);
		}
		return null;
	}

	Chunk@ getChunkSafe(int index)
	{
		if (isValidChunk(index))
		{
			return getChunk(index);
		}
		return null;
	}

	Chunk@ getChunk(Vec3f position)
	{
		return getChunk(position.x, position.y, position.z);
	}


	Chunk@ getChunk(int x, int y, int z)
	{
		return getChunk(chunkPosToChunkIndex(x, y, z));
	}

	Chunk@ getChunk(int index)
	{
		return chunks[index];
	}

	u8 getFaceFlags(int index)
	{
		return faceFlags[index];
	}

	bool blockHasFace(int index, u8 face)
	{
		return (faceFlags[index] & face) == face;
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

	private void PreventXray()
	{
		Vec3f position = camera.interPosition;
		if (!map.isValidBlock(position)) return;

		Vec3f worldPos = position.floor();
		Vec3f center = worldPos + 0.5f;
		Vec3f dir = (center - position).sign();

		Vertex[] vertices;
		u16[] indices;

		getSurroundingBlockFaces(worldPos, vertices, indices);

		if (dir.x != 0)
		{
			Vec3f pos = worldPos - Vec3f(dir.x, 0, 0);
			if (pos.x >= 0 && pos.x < map.dimensions.x)
			{
				getSurroundingBlockFaces(pos, vertices, indices);
			}
		}

		if (dir.y != 0)
		{
			Vec3f pos = worldPos - Vec3f(0, dir.y, 0);
			if (pos.y >= 0 && pos.y < map.dimensions.y)
			{
				getSurroundingBlockFaces(pos, vertices, indices);
			}
		}

		if (dir.z != 0)
		{
			Vec3f pos = worldPos - Vec3f(0, 0, dir.z);
			if (pos.z >= 0 && pos.z < map.dimensions.z)
			{
				getSurroundingBlockFaces(pos, vertices, indices);
			}
		}

		if (!vertices.empty())
		{
			xrayMesh.SetVertex(vertices);
			xrayMesh.SetIndices(indices);
			xrayMesh.SetDirty(SMesh::VERTEX_INDEX);
			xrayMesh.BuildMesh();

			xrayMesh.RenderMesh();
		}
		else
		{
			xrayMesh.Clear();
		}
	}

	private void getSurroundingBlockFaces(Vec3f worldPos, Vertex[]@ vertices, u16[]@ indices)
	{
		SColor block = map.getBlock(worldPos);
		if (!map.isVisible(block)) return;

		int index = map.posToIndex(worldPos);

		float x1 = 0;
		float y1 = 0;
		float x2 = 1;
		float y2 = 1;

		float w = 1;

		if (!blockHasFace(index, FaceFlag::Left))
		{
			Vec3f pos = worldPos + Vec3f(-1, 0, 0);
			block = map.getBlock(pos);
			SColor col = getBlockFaceColor(block, Face::Right);

			vertices.push_back(Vertex(pos.x + w, pos.y + w, pos.z    , x1, y1, col));
			vertices.push_back(Vertex(pos.x + w, pos.y + w, pos.z + w, x2, y1, col));
			vertices.push_back(Vertex(pos.x + w, pos.y    , pos.z + w, x2, y2, col));
			vertices.push_back(Vertex(pos.x + w, pos.y    , pos.z    , x1, y2, col));
			AddIndices(vertices, indices);
		}

		if (!blockHasFace(index, FaceFlag::Right))
		{
			Vec3f pos = worldPos + Vec3f(1, 0, 0);
			block = map.getBlock(pos);
			SColor col = getBlockFaceColor(block, Face::Left);

			vertices.push_back(Vertex(pos.x, pos.y + w, pos.z + w, x1, y1, col));
			vertices.push_back(Vertex(pos.x, pos.y + w, pos.z    , x2, y1, col));
			vertices.push_back(Vertex(pos.x, pos.y    , pos.z    , x2, y2, col));
			vertices.push_back(Vertex(pos.x, pos.y    , pos.z + w, x1, y2, col));
			AddIndices(vertices, indices);
		}

		if (!blockHasFace(index, FaceFlag::Down))
		{
			Vec3f pos = worldPos + Vec3f(0, -1, 0);
			block = map.getBlock(pos);
			SColor col = getBlockFaceColor(block, Face::Up);

			vertices.push_back(Vertex(pos.x    , pos.y + w, pos.z + w, x1, y1, col));
			vertices.push_back(Vertex(pos.x + w, pos.y + w, pos.z + w, x2, y1, col));
			vertices.push_back(Vertex(pos.x + w, pos.y + w, pos.z    , x2, y2, col));
			vertices.push_back(Vertex(pos.x    , pos.y + w, pos.z    , x1, y2, col));
			AddIndices(vertices, indices);
		}

		if (!blockHasFace(index, FaceFlag::Up))
		{
			Vec3f pos = worldPos + Vec3f(0, 1, 0);
			block = map.getBlock(pos);
			SColor col = getBlockFaceColor(block, Face::Down);

			vertices.push_back(Vertex(pos.x + w, pos.y, pos.z + w, x1, y1, col));
			vertices.push_back(Vertex(pos.x    , pos.y, pos.z + w, x2, y1, col));
			vertices.push_back(Vertex(pos.x    , pos.y, pos.z    , x2, y2, col));
			vertices.push_back(Vertex(pos.x + w, pos.y, pos.z    , x1, y2, col));
			AddIndices(vertices, indices);
		}

		if (!blockHasFace(index, FaceFlag::Front))
		{
			Vec3f pos = worldPos + Vec3f(0, 0, -1);
			block = map.getBlock(pos);
			SColor col = getBlockFaceColor(block, Face::Back);

			vertices.push_back(Vertex(pos.x + w, pos.y + w, pos.z + w, x1, y1, col));
			vertices.push_back(Vertex(pos.x    , pos.y + w, pos.z + w, x2, y1, col));
			vertices.push_back(Vertex(pos.x    , pos.y    , pos.z + w, x2, y2, col));
			vertices.push_back(Vertex(pos.x + w, pos.y    , pos.z + w, x1, y2, col));
			AddIndices(vertices, indices);
		}

		if (!blockHasFace(index, FaceFlag::Back))
		{
			Vec3f pos = worldPos + Vec3f(0, 0, 1);
			block = map.getBlock(pos);
			SColor col = getBlockFaceColor(block, Face::Front);

			vertices.push_back(Vertex(pos.x    , pos.y + w, pos.z, x1, y1, col));
			vertices.push_back(Vertex(pos.x + w, pos.y + w, pos.z, x2, y1, col));
			vertices.push_back(Vertex(pos.x + w, pos.y    , pos.z, x2, y2, col));
			vertices.push_back(Vertex(pos.x    , pos.y    , pos.z, x1, y2, col));
			AddIndices(vertices, indices);
		}
	}

	private void AddIndices(Vertex[]@ vertices, u16[]@ indices)
	{
		uint n = vertices.size();
		indices.push_back(n - 4);
		indices.push_back(n - 3);
		indices.push_back(n - 1);
		indices.push_back(n - 3);
		indices.push_back(n - 2);
		indices.push_back(n - 1);
	}

	SColor getBlockFaceColor(SColor block, u8 face)
	{
		float shade = 1 - shadeIntensity * shadeScale[face];
		float health = map.getHealth(block) / 255.0f;

		return SColor(255,
			block.getRed() * shade * health,
			block.getGreen() * shade * health,
			block.getBlue() * shade * health
		);
	}
}
