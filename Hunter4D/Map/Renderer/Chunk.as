#include "AABB.as"

shared class Chunk
{
	Map@ map;
	MapRenderer@ renderer;

	uint index;
	Vec3f position;

	AABB bounds;

	SMesh mesh;
	Vertex[] vertices;
	u16[] indices;

	bool rebuild = true;

	Chunk(MapRenderer@ renderer, uint index)
	{
		@this.renderer = renderer;
		@map = renderer.map;

		this.index = index;
		position = renderer.chunkIndexToPos(index);

		bounds = AABB(position * renderer.chunkDimension, (position + 1) * renderer.chunkDimension);

		mesh.SetHardwareMapping(SMesh::STATIC);

		GenerateMesh();
	}

	void Render()
	{
		if (rebuild)
		{
			GenerateMesh();
		}

		if (!vertices.empty())
		{
			mesh.RenderMesh();
		}
	}

	private void AddIndices()
	{
		uint n = vertices.size();
		indices.push_back(n - 4);
		indices.push_back(n - 3);
		indices.push_back(n - 1);
		indices.push_back(n - 3);
		indices.push_back(n - 2);
		indices.push_back(n - 1);
	}

	void GenerateMesh()
	{
		rebuild = false;

		vertices.clear();
		indices.clear();

		Vec3f startWorldPos = position * renderer.chunkDimension;
		Vec3f endWorldPos = (startWorldPos + renderer.chunkDimension).min(map.dimensions);

		for (uint x = startWorldPos.x; x < endWorldPos.x; x++)
		for (uint y = startWorldPos.y; y < endWorldPos.y; y++)
		for (uint z = startWorldPos.z; z < endWorldPos.z; z++)
		{
			int index = renderer.map.posToIndex(x, y, z);

			if (renderer.getFaceFlags(index) != FaceFlag::None)
			{
				SColor block = map.getBlock(index);

				float x1 = 0;
				float y1 = 0;
				float x2 = 1;
				float y2 = 1;

				float w = 1;

				if (renderer.blockHasFace(index, FaceFlag::Left))
				{
					SColor col = renderer.getBlockFaceColor(block, Face::Left);
					vertices.push_back(Vertex(x, y + w, z + w, x1, y1, col));
					vertices.push_back(Vertex(x, y + w, z    , x2, y1, col));
					vertices.push_back(Vertex(x, y    , z    , x2, y2, col));
					vertices.push_back(Vertex(x, y    , z + w, x1, y2, col));
					AddIndices();
				}

				if (renderer.blockHasFace(index, FaceFlag::Right))
				{
					SColor col = renderer.getBlockFaceColor(block, Face::Right);
					vertices.push_back(Vertex(x + w, y + w, z    , x1, y1, col));
					vertices.push_back(Vertex(x + w, y + w, z + w, x2, y1, col));
					vertices.push_back(Vertex(x + w, y    , z + w, x2, y2, col));
					vertices.push_back(Vertex(x + w, y    , z    , x1, y2, col));
					AddIndices();
				}

				if (renderer.blockHasFace(index, FaceFlag::Down))
				{
					SColor col = renderer.getBlockFaceColor(block, Face::Down);
					vertices.push_back(Vertex(x + w, y, z + w, x1, y1, col));
					vertices.push_back(Vertex(x    , y, z + w, x2, y1, col));
					vertices.push_back(Vertex(x    , y, z    , x2, y2, col));
					vertices.push_back(Vertex(x + w, y, z    , x1, y2, col));
					AddIndices();
				}

				if (renderer.blockHasFace(index, FaceFlag::Up))
				{
					SColor col =  renderer.getBlockFaceColor(block, Face::Up);
					vertices.push_back(Vertex(x    , y + w, z + w, x1, y1, col));
					vertices.push_back(Vertex(x + w, y + w, z + w, x2, y1, col));
					vertices.push_back(Vertex(x + w, y + w, z    , x2, y2, col));
					vertices.push_back(Vertex(x    , y + w, z    , x1, y2, col));
					AddIndices();
				}

				if (renderer.blockHasFace(index, FaceFlag::Front))
				{
					SColor col = renderer.getBlockFaceColor(block, Face::Front);
					vertices.push_back(Vertex(x    , y + w, z, x1, y1, col));
					vertices.push_back(Vertex(x + w, y + w, z, x2, y1, col));
					vertices.push_back(Vertex(x + w, y    , z, x2, y2, col));
					vertices.push_back(Vertex(x    , y    , z, x1, y2, col));
					AddIndices();
				}

				if (renderer.blockHasFace(index, FaceFlag::Back))
				{
					SColor col = renderer.getBlockFaceColor(block, Face::Back);
					vertices.push_back(Vertex(x + w, y + w, z + w, x1, y1, col));
					vertices.push_back(Vertex(x    , y + w, z + w, x2, y1, col));
					vertices.push_back(Vertex(x    , y    , z + w, x2, y2, col));
					vertices.push_back(Vertex(x + w, y    , z + w, x1, y2, col));
					AddIndices();
				}
			}
		}

		if (!vertices.empty())
		{
			mesh.SetVertex(vertices);
			mesh.SetIndices(indices);
			mesh.SetDirty(SMesh::VERTEX_INDEX);
			mesh.BuildMesh();
		}
		else
		{
			mesh.Clear();
		}
	}
}
