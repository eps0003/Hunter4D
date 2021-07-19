#include "Plane.as"
#include "AABB.as"

shared class Frustum
{
	private Plane plane0;
	private Plane plane1;
	private Plane plane2;
	private Plane plane3;
	private Plane plane4;
	private Plane plane5;

	void Update(float[] matrix)
	{
		// Left clipping plane
		plane2.normal.x         = matrix[3]  + matrix[0];
		plane2.normal.y         = matrix[7]  + matrix[4];
		plane2.normal.z         = matrix[11] + matrix[8];
		plane2.distanceToOrigin = matrix[15] + matrix[12];

		// Right clipping plane
		plane3.normal.x         = matrix[3]  - matrix[0];
		plane3.normal.y         = matrix[7]  - matrix[4];
		plane3.normal.z         = matrix[11] - matrix[8];
		plane3.distanceToOrigin = matrix[15] - matrix[12];

		// Top clipping plane
		plane4.normal.x         = matrix[3]  - matrix[1];
		plane4.normal.y         = matrix[7]  - matrix[5];
		plane4.normal.z         = matrix[11] - matrix[9];
		plane4.distanceToOrigin = matrix[15] - matrix[13];

		// Bottom clipping plane
		plane5.normal.x         = matrix[3]  + matrix[1];
		plane5.normal.y         = matrix[7]  + matrix[5];
		plane5.normal.z         = matrix[11] + matrix[9];
		plane5.distanceToOrigin = matrix[15] + matrix[13];

		// Far clipping plane
		plane1.normal.x         = matrix[3]  - matrix[2];
		plane1.normal.y         = matrix[7]  - matrix[6];
		plane1.normal.z         = matrix[11] - matrix[10];
		plane1.distanceToOrigin = matrix[15] - matrix[14];

		// Near clipping plane
		plane0.normal.x         = matrix[2];
		plane0.normal.y         = matrix[6];
		plane0.normal.z         = matrix[10];
		plane0.distanceToOrigin = matrix[14];

		plane0.Normalize();
		plane1.Normalize();
		plane2.Normalize();
		plane3.Normalize();
		plane4.Normalize();
		plane5.Normalize();
	}

	bool containsAABB(AABB box)
	{
		if (!plane0.intersects(box))
			return false;
		if (!plane1.intersects(box))
			return false;
		if (!plane2.intersects(box))
			return false;
		if (!plane3.intersects(box))
			return false;
		if (!plane4.intersects(box))
			return false;
		if (!plane5.intersects(box))
			return false;
		return true;
	}

	bool containsPoint(Vec3f point)
	{
		if (plane0.distanceToPoint(point) < 0)
			return false;
		if (plane1.distanceToPoint(point) < 0)
			return false;
		if (plane2.distanceToPoint(point) < 0)
			return false;
		if (plane3.distanceToPoint(point) < 0)
			return false;
		if (plane4.distanceToPoint(point) < 0)
			return false;
		if (plane5.distanceToPoint(point) < 0)
			return false;
		return true;
	}

	bool containsSphere(Vec3f point, float radius)
	{
		if (plane0.distanceToPoint(point) < -radius)
			return false;
		if (plane1.distanceToPoint(point) < -radius)
			return false;
		if (plane2.distanceToPoint(point) < -radius)
			return false;
		if (plane3.distanceToPoint(point) < -radius)
			return false;
		if (plane4.distanceToPoint(point) < -radius)
			return false;
		if (plane5.distanceToPoint(point) < -radius)
			return false;
		return true;
	}
}
