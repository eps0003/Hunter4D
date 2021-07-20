#include "Map.as"
#include "Camera.as"

shared class Tree
{
	private Branch@ branch;

	private Camera@ camera = Camera::getCamera();
	private MapRenderer@ mapRenderer = Map::getRenderer();

	Tree()
	{
		@branch = Branch(mapRenderer, Vec3f(), Vec3f(mapRenderer.chunkDimensions.max()));
	}

	Chunk@[] getVisibleChunks()
	{
		Chunk@[] chunks;
		branch.GetVisibleChunks(camera.getFrustum(), camera.interPosition, chunks);
		return chunks;
	}
}

shared class Branch
{
	private AABB bounds;
	private AABB worldBounds;

	private Branch@ branch0;
	private Branch@ branch1;
	private Branch@ branch2;
	private Branch@ branch3;
	private Branch@ branch4;
	private Branch@ branch5;
	private Branch@ branch6;
	private Branch@ branch7;

	private Chunk@ chunk0;
	private Chunk@ chunk1;
	private Chunk@ chunk2;
	private Chunk@ chunk3;
	private Chunk@ chunk4;
	private Chunk@ chunk5;
	private Chunk@ chunk6;
	private Chunk@ chunk7;

	Branch(MapRenderer@ mapRenderer, Vec3f min, Vec3f max)
	{
		bounds = AABB(min, max);
		worldBounds = AABB(min * mapRenderer.chunkDimension, max * mapRenderer.chunkDimension);

		min = bounds.min;
		max = bounds.max;
		Vec3f dim = bounds.dim;
		Vec3f chunkDim = mapRenderer.chunkDimensions;

		// Check if branch can be subdivided
		if (bounds.dim.max() > 2)
		{
			Vec3f half = min + (dim / 2.0f).floor();

			// Subdivide bottom half
			@branch0 = Branch(mapRenderer, Vec3f(min.x, min.y, min.z), Vec3f(half.x, half.y, half.z));

			if (half.x < chunkDim.x)
			{
				@branch1 = Branch(mapRenderer, Vec3f(half.x, min.y, min.z), Vec3f(max.x, half.y, half.z));
			}

			if (half.z < chunkDim.z)
			{
				@branch2 = Branch(mapRenderer, Vec3f(min.x, min.y, half.z), Vec3f(half.x, half.y, max.z));

				if (half.x < chunkDim.x)
				{
					@branch3 = Branch(mapRenderer, Vec3f(half.x, min.y, half.z), Vec3f(max.x, half.y, max.z));
				}
			}

			// Subdivide top half
			if (half.y < chunkDim.y)
			{
				@branch4 = Branch(mapRenderer, Vec3f(min.x, half.y, min.z), Vec3f(half.x, max.y, half.z));

				if (half.x < chunkDim.x)
				{
					@branch5 = Branch(mapRenderer, Vec3f(half.x, half.y, min.z), Vec3f(max.x, max.y, half.z));
				}

				if (half.z < chunkDim.z)
				{
					@branch6 = Branch(mapRenderer, Vec3f(min.x, half.y, half.z), Vec3f(half.x, max.y, max.z));

					if (half.x < chunkDim.x)
					{
						@branch7 = Branch(mapRenderer, Vec3f(half.x, half.y, half.z), Vec3f(max.x, max.y,  max.z));
					}
				}
			}
		}
		else
		{
			// Get bottom chunks
			@chunk0 = mapRenderer.getChunk(min.x, min.y, min.z);

			if (min.x + 1 < chunkDim.x)
			{
				@chunk1 = mapRenderer.getChunk(min.x + 1, min.y, min.z);
			}

			if (min.z + 1 < chunkDim.z)
			{
				@chunk2 = mapRenderer.getChunk(min.x, min.y, min.z + 1);

				if (min.x + 1 < chunkDim.x)
				{
					@chunk3 = mapRenderer.getChunk(min.x + 1, min.y, min.z + 1);
				}
			}

			// Get top chunks
			if (min.y + 1 < chunkDim.y)
			{
				@chunk4 = mapRenderer.getChunk(min.x, min.y + 1, min.z);

				if (min.x + 1 < chunkDim.x)
				{
					@chunk5 = mapRenderer.getChunk(min.x + 1, min.y + 1, min.z);
				}

				if (min.z + 1 < chunkDim.z)
				{
					@chunk6 = mapRenderer.getChunk(min.x, min.y + 1, min.z + 1);

					if (min.x + 1 < chunkDim.x)
					{
						@chunk7 = mapRenderer.getChunk(min.x + 1, min.y + 1, min.z + 1);
					}
				}
			}
		}
	}

	void GetVisibleChunks(Frustum frustum, Vec3f camPos, Chunk@[]@ visibleChunks)
	{
		if (frustum.containsSphere(worldBounds.center - camPos, worldBounds.corner))
		{
			if (chunk0 !is null)
			{
				uint index = visibleChunks.size();

				bool c0 = frustum.containsSphere(chunk0.bounds.center - camPos, chunk0.bounds.corner);
				bool c1 = chunk1 !is null && frustum.containsSphere(chunk1.bounds.center - camPos, chunk1.bounds.corner);
				bool c2 = chunk2 !is null && frustum.containsSphere(chunk2.bounds.center - camPos, chunk2.bounds.corner);
				bool c3 = chunk3 !is null && frustum.containsSphere(chunk3.bounds.center - camPos, chunk3.bounds.corner);
				bool c4 = chunk4 !is null && frustum.containsSphere(chunk4.bounds.center - camPos, chunk4.bounds.corner);
				bool c5 = chunk5 !is null && frustum.containsSphere(chunk5.bounds.center - camPos, chunk5.bounds.corner);
				bool c6 = chunk6 !is null && frustum.containsSphere(chunk6.bounds.center - camPos, chunk6.bounds.corner);
				bool c7 = chunk7 !is null && frustum.containsSphere(chunk7.bounds.center - camPos, chunk7.bounds.corner);

				u8 visibleCount = 0;
				if (c0) visibleCount++;
				if (c1) visibleCount++;
				if (c2) visibleCount++;
				if (c3) visibleCount++;
				if (c4) visibleCount++;
				if (c5) visibleCount++;
				if (c6) visibleCount++;
				if (c7) visibleCount++;

				visibleChunks.set_length(index + visibleCount);

				if (c0) @visibleChunks[index++] = chunk0;
				if (c1) @visibleChunks[index++] = chunk1;
				if (c2) @visibleChunks[index++] = chunk2;
				if (c3) @visibleChunks[index++] = chunk3;
				if (c4) @visibleChunks[index++] = chunk4;
				if (c5) @visibleChunks[index++] = chunk5;
				if (c6) @visibleChunks[index++] = chunk6;
				if (c7) @visibleChunks[index++] = chunk7;
			}
			else
			{
				branch0.GetVisibleChunks(frustum, camPos, visibleChunks);
				if (branch1 !is null) branch1.GetVisibleChunks(frustum, camPos, visibleChunks);
				if (branch2 !is null) branch2.GetVisibleChunks(frustum, camPos, visibleChunks);
				if (branch3 !is null) branch3.GetVisibleChunks(frustum, camPos, visibleChunks);
				if (branch4 !is null) branch4.GetVisibleChunks(frustum, camPos, visibleChunks);
				if (branch5 !is null) branch5.GetVisibleChunks(frustum, camPos, visibleChunks);
				if (branch6 !is null) branch6.GetVisibleChunks(frustum, camPos, visibleChunks);
				if (branch7 !is null) branch7.GetVisibleChunks(frustum, camPos, visibleChunks);
			}
		}
	}
}
