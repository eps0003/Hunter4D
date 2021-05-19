class Chunk
{
	MapRenderer@ renderer;

	SMesh mesh;
	Vertex[] vertices;
	u16[] indices;

	Chunk(MapRenderer@ renderer, uint index)
	{
		@this.renderer = renderer;

		mesh.SetHardwareMapping(SMesh::STATIC);
	}

	void Render()
	{
		mesh.RenderMesh();
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

	private bool blockHasFace(u8 flags, u8 face)
	{
		return (flags & face) == face;
	}

	int posToIndex(int x, int y, int z)
	{
		u8 dim = renderer.chunkDimension;
		return x + (y * dim) + (z * dim * dim);
	}

	Vec3f indexToPos(int index)
	{
		u8 dim = renderer.chunkDimension;
		Vec3f vec;
		vec.x = index % dim;
		vec.y = Maths::Floor(index / dim) % dim;
		vec.z = Maths::Floor(index / (dim * dim));
		return vec;
	}

	void GenerateMesh(Map@ map, uint chunkIndex)
	{
		vertices.clear();
		indices.clear();

		Vec3f chunkPos = indexToPos(chunkIndex);

		Vec3f startWorldPos = chunkPos * renderer.chunkDimension;
		Vec3f endWorldPos = (startWorldPos + renderer.chunkDimension).min(map.dimensions);

		for (uint x = startWorldPos.x; x < endWorldPos.x; x++)
		for (uint y = startWorldPos.y; y < endWorldPos.y; y++)
		for (uint z = startWorldPos.z; z < endWorldPos.z; z++)
		{
			int index = map.posToIndex(x, y, z);

			renderer.UpdateBlockFaces(map, x, y, z);
			u8 faces = renderer.faceFlags[index];

			if (faces != FaceFlag::None)
			{
				u8 block = map.getBlock(index);
				Block@ blockType = Block::getBlock(block);

				float x1 = block / 8.0f;
				float y1 = Maths::Floor(x1) / 32.0f;
				float x2 = x1 + (1.0f / 32.0f);
				float y2 = y1 + (1.0f / 32.0f);

				float w = 1;

				SColor col;
				// float shade = 12;
				// SColor[] colors = {
				// 	SColor(255, 255 - shade * 2, 255 - shade * 2, 255 - shade * 2),
				// 	SColor(255, 255 - shade * 3, 255 - shade * 3, 255 - shade * 3),
				// 	SColor(255, 255 - shade * 5, 255 - shade * 5, 255 - shade * 5),
				// 	SColor(255, 255 - shade * 0, 255 - shade * 0, 255 - shade * 0),
				// 	SColor(255, 255 - shade * 1, 255 - shade * 1, 255 - shade * 1),
				// 	SColor(255, 255 - shade * 4, 255 - shade * 4, 255 - shade * 4),
				// };

				if (blockHasFace(faces, FaceFlag::Left))
				{
					col = color_white;
					vertices.push_back(Vertex(x, y + w, z + w, x1, y1, col));
					vertices.push_back(Vertex(x, y + w, z    , x2, y1, col));
					vertices.push_back(Vertex(x, y    , z    , x2, y2, col));
					vertices.push_back(Vertex(x, y    , z + w, x1, y2, col));
					AddIndices();
				}

				if (blockHasFace(faces, FaceFlag::Right))
				{
					col = color_white;
					vertices.push_back(Vertex(x + w, y + w, z    , x1, y1, col));
					vertices.push_back(Vertex(x + w, y + w, z + w, x2, y1, col));
					vertices.push_back(Vertex(x + w, y    , z + w, x2, y2, col));
					vertices.push_back(Vertex(x + w, y    , z    , x1, y2, col));
					AddIndices();
				}

				if (blockHasFace(faces, FaceFlag::Down))
				{
					col = color_white;
					vertices.push_back(Vertex(x + w, y, z + w, x1, y1, col));
					vertices.push_back(Vertex(x    , y, z + w, x2, y1, col));
					vertices.push_back(Vertex(x    , y, z    , x2, y2, col));
					vertices.push_back(Vertex(x + w, y, z    , x1, y2, col));
					AddIndices();
				}

				if (blockHasFace(faces, FaceFlag::Up))
				{
					col = color_white;
					vertices.push_back(Vertex(x    , y + w, z + w, x1, y1, col));
					vertices.push_back(Vertex(x + w, y + w, z + w, x2, y1, col));
					vertices.push_back(Vertex(x + w, y + w, z    , x2, y2, col));
					vertices.push_back(Vertex(x    , y + w, z    , x1, y2, col));
					AddIndices();
				}

				if (blockHasFace(faces, FaceFlag::Front))
				{
					col = color_white;
					vertices.push_back(Vertex(x    , y + w, z, x1, y1, col));
					vertices.push_back(Vertex(x + w, y + w, z, x2, y1, col));
					vertices.push_back(Vertex(x + w, y    , z, x2, y2, col));
					vertices.push_back(Vertex(x    , y    , z, x1, y2, col));
					AddIndices();
				}

				if (blockHasFace(faces, FaceFlag::Back))
				{
					col = color_white;
					vertices.push_back(Vertex(x + w, y + w, z + w, x1, y1, col));
					vertices.push_back(Vertex(x    , y + w, z + w, x2, y1, col));
					vertices.push_back(Vertex(x    , y    , z + w, x2, y2, col));
					vertices.push_back(Vertex(x + w, y    , z + w, x1, y2, col));
					AddIndices();
				}

				// if (blockType.transparent)
				// {
				// 	float o = 0.005f;

				// 	//right inner
				// 	col = colors[Direction::Left];
				// 	vertices.push_back(Vertex(x + w - o, y + w, z + w, x1, y1, col));
				// 	vertices.push_back(Vertex(x + w - o, y + w, z    , x2, y1, col));
				// 	vertices.push_back(Vertex(x + w - o, y    , z    , x2, y2, col));
				// 	vertices.push_back(Vertex(x + w - o, y    , z + w, x1, y2, col));
				// 	AddIndices();

				// 	//left inner
				// 	col = colors[Direction::Right];
				// 	vertices.push_back(Vertex(x + o, y + w, z    , x1, y1, col));
				// 	vertices.push_back(Vertex(x + o, y + w, z + w, x2, y1, col));
				// 	vertices.push_back(Vertex(x + o, y    , z + w, x2, y2, col));
				// 	vertices.push_back(Vertex(x + o, y    , z    , x1, y2, col));
				// 	AddIndices();

				// 	//up inner
				// 	col = colors[Direction::Down];
				// 	vertices.push_back(Vertex(x + w, y + w - o, z + w, x1, y1, col));
				// 	vertices.push_back(Vertex(x    , y + w - o, z + w, x2, y1, col));
				// 	vertices.push_back(Vertex(x    , y + w - o, z    , x2, y2, col));
				// 	vertices.push_back(Vertex(x + w, y + w - o, z    , x1, y2, col));
				// 	AddIndices();

				// 	//down inner
				// 	col = colors[Direction::Up];
				// 	vertices.push_back(Vertex(x    , y + o, z + w, x1, y1, col));
				// 	vertices.push_back(Vertex(x + w, y + o, z + w, x2, y1, col));
				// 	vertices.push_back(Vertex(x + w, y + o, z    , x2, y2, col));
				// 	vertices.push_back(Vertex(x    , y + o, z    , x1, y2, col));
				// 	AddIndices();

				// 	//back inner
				// 	col = colors[Direction::Front];
				// 	vertices.push_back(Vertex(x    , y + w, z + w - o, x1, y1, col));
				// 	vertices.push_back(Vertex(x + w, y + w, z + w - o, x2, y1, col));
				// 	vertices.push_back(Vertex(x + w, y    , z + w - o, x2, y2, col));
				// 	vertices.push_back(Vertex(x    , y    , z + w - o, x1, y2, col));
				// 	AddIndices();

				// 	//front inner
				// 	col = colors[Direction::Back];
				// 	vertices.push_back(Vertex(x + w, y + w, z + o, x1, y1, col));
				// 	vertices.push_back(Vertex(x    , y + w, z + o, x2, y1, col));
				// 	vertices.push_back(Vertex(x    , y    , z + o, x2, y2, col));
				// 	vertices.push_back(Vertex(x + w, y    , z + o, x1, y2, col));
				// 	AddIndices();
				// }
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
