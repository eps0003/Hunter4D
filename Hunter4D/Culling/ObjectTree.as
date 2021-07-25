#include "Map.as"
#include "Camera.as"

shared class ObjectTree
{
	private ObjectTreeBranch@ branch;

	private Map@ map = Map::getMap();
	private Camera@ camera = Camera::getCamera();

	ObjectTree()
	{
		Object@[] objects = Object::getObjects();
		if (!objects.empty())
		{
			Vec3f min, max;
			getRootBounds(objects, min, max);

			@branch = ObjectTreeBranch(min, max);

			for (int i = objects.size() - 1; i >= 0; i--)
			{
				branch.InsertObject(objects[i]);
			}
		}
	}

	uint RenderVisibleObjects()
	{
		if (branch !is null)
		{
			return branch.RenderVisibleObjects(camera.getFrustum(), camera.interPosition);
		}
		return 0;
	}
}

shared class ObjectTreeBranch
{
	private u8 maxObjects = 1;
	private AABB@ bounds;

	private ObjectTreeBranch@ branch0;
	private ObjectTreeBranch@ branch1;
	private ObjectTreeBranch@ branch2;
	private ObjectTreeBranch@ branch3;
	private ObjectTreeBranch@ branch4;
	private ObjectTreeBranch@ branch5;
	private ObjectTreeBranch@ branch6;
	private ObjectTreeBranch@ branch7;

	private Object@[] objects;

	ObjectTreeBranch(Vec3f@ min, Vec3f@ max)
	{
		@bounds = AABB(min, max);
		objects.reserve(maxObjects + 1);
	}

	uint RenderVisibleObjects(Frustum@ frustum, Vec3f camPos)
	{
		uint visibleObjectCount = 0;

		if (frustum.containsSphere(bounds.center - camPos, bounds.radius))
		{
			for (int i = objects.size() - 1; i >= 0; i--)
			{
				Object@ object = objects[i];

				object.Interpolate();
				if (object.isVisible())
				{
					object.Render();
					visibleObjectCount++;
				}
			}

			if (branch0 !is null) visibleObjectCount += branch0.RenderVisibleObjects(frustum, camPos);
			if (branch1 !is null) visibleObjectCount += branch1.RenderVisibleObjects(frustum, camPos);
			if (branch2 !is null) visibleObjectCount += branch2.RenderVisibleObjects(frustum, camPos);
			if (branch3 !is null) visibleObjectCount += branch3.RenderVisibleObjects(frustum, camPos);
			if (branch4 !is null) visibleObjectCount += branch4.RenderVisibleObjects(frustum, camPos);
			if (branch5 !is null) visibleObjectCount += branch5.RenderVisibleObjects(frustum, camPos);
			if (branch6 !is null) visibleObjectCount += branch6.RenderVisibleObjects(frustum, camPos);
			if (branch7 !is null) visibleObjectCount += branch7.RenderVisibleObjects(frustum, camPos);
		}

		return visibleObjectCount;
	}

	void InsertObject(Object@ object)
	{
		if (branch0 !is null && tryInsert(object))
		{
			return;
		}

		objects.push_back(object);

		if (branch0 is null && objects.size() > maxObjects)
		{
			Split();

			for (int i = objects.size() - 1; i >= 0; i--)
			{
				Object@ object = objects[i];
				if (tryInsert(object))
				{
					objects.removeAt(i);
				}
			}
		}
	}

	uint getDepth()
	{
		uint count = 0;
		if (branch0 !is null)
		{
			count = Maths::Max(count, branch0.getDepth());
			count = Maths::Max(count, branch1.getDepth());
			count = Maths::Max(count, branch2.getDepth());
			count = Maths::Max(count, branch3.getDepth());
			count = Maths::Max(count, branch4.getDepth());
			count = Maths::Max(count, branch5.getDepth());
			count = Maths::Max(count, branch6.getDepth());
			count = Maths::Max(count, branch7.getDepth());
		}
		return count + 1;
	}

	private bool tryInsert(Object@ object)
	{
		Vec3f@ objCenter = object.getCenter();
		float radius = object.getCullRadius();
		AABB objBounds(objCenter - radius, objCenter + radius);

		if (branch0.containsObject(objBounds))
		{
			branch0.InsertObject(object);
			return true;
		}

		if (branch1.containsObject(objBounds))
		{
			branch1.InsertObject(object);
			return true;
		}

		if (branch2.containsObject(objBounds))
		{
			branch2.InsertObject(object);
			return true;
		}

		if (branch3.containsObject(objBounds))
		{
			branch3.InsertObject(object);
			return true;
		}

		if (branch4.containsObject(objBounds))
		{
			branch4.InsertObject(object);
			return true;
		}

		if (branch5.containsObject(objBounds))
		{
			branch5.InsertObject(object);
			return true;
		}

		if (branch6.containsObject(objBounds))
		{
			branch6.InsertObject(object);
			return true;
		}

		if (branch7.containsObject(objBounds))
		{
			branch7.InsertObject(object);
			return true;
		}

		return false;
	}

	private void Split()
	{
		Vec3f@ min = bounds.min;
		Vec3f@ max = bounds.max;
		Vec3f@ half = bounds.min + (bounds.dim * 0.5f);

		@branch0 = ObjectTreeBranch(min, half);
		@branch1 = ObjectTreeBranch(Vec3f(half.x, min.y, min.z), Vec3f(max.x, half.y, half.z));
		@branch2 = ObjectTreeBranch(Vec3f(min.x, min.y, half.z), Vec3f(half.x, half.y, max.z));
		@branch3 = ObjectTreeBranch(Vec3f(half.x, min.y, half.z), Vec3f(max.x, half.y, max.z));

		@branch4 = ObjectTreeBranch(Vec3f(min.x, half.y, min.z), Vec3f(half.x, max.y, half.z));
		@branch5 = ObjectTreeBranch(Vec3f(half.x, half.y, min.z), Vec3f(max.x, max.y, half.z));
		@branch6 = ObjectTreeBranch(Vec3f(min.x, half.y, half.z), Vec3f(half.x, max.y, max.z));
		@branch7 = ObjectTreeBranch(half, max);
	}

	private bool containsObject(AABB@ objBounds)
	{
		return (
			bounds.min.x <= objBounds.min.x &&
			bounds.max.x >= objBounds.max.x &&
			bounds.min.y <= objBounds.min.y &&
			bounds.max.y >= objBounds.max.y &&
			bounds.min.z <= objBounds.min.z &&
			bounds.max.z >= objBounds.max.z
		);
	}
}

shared void getRootBounds(Object@[]@ objects, Vec3f &out min, Vec3f &out max)
{
	uint size = objects.size();
	for (uint i = 0; i < size; i++)
	{
		Object@ object = objects[i];

		Vec3f@ objMin = object.interPosition - object.getCullRadius();
		Vec3f@ objMax = object.interPosition + object.getCullRadius();

		if (i == 0)
		{
			min = objMin;
			max = objMax;
		}
		else
		{
			if (objMin.x < min.x) min.x = objMin.x;
			if (objMin.y < min.y) min.y = objMin.y;
			if (objMin.z < min.z) min.z = objMin.z;
			if (objMax.x > max.x) max.x = objMax.x;
			if (objMax.y > max.y) max.y = objMax.y;
			if (objMax.z > max.z) max.z = objMax.z;
		}
	}
}
