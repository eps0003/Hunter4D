#include "Vec3f.as"
#include "AABB.as"

shared class Plane
{
	Vec3f normal;
	float distanceToOrigin = 0.0f;

	Plane(Vec3f normal, float scalar)
	{
		this.normal = normal;
		distanceToOrigin = scalar;
	}

	bool intersects(AABB box)
	{
		float d = box.center.dot(normal);
		float r = box.dim.x * Maths::Abs(normal.x) + box.dim.y * Maths::Abs(normal.y) + box.dim.z * Maths::Abs(normal.z);
		float dpr = d + r;

		return dpr >= -distanceToOrigin;
	}

	float distanceToPoint(Vec3f point)
	{
		return normal.dot(point) + distanceToOrigin;
	}

	void Normalize()
	{
		float mag = normal.mag();
		normal /= mag;
		distanceToOrigin /= mag;
	}

	// Stolen from GoldenGuy who stole it from irrlicht :)
	bool getIntersectionWithPlane(Plane other, Vec3f linePoint, Vec3f &out lineVec)
	{
		float fn00 = normal.magSquared();
		float fn01 = normal.dot(other.normal);
		float fn11 = other.normal.magSquared();
		float det = fn00 * fn11 - fn01 * fn01;

		if (Maths::Abs(det) < 0.0000001f)
		{
			return false;
		}

		float invdet = 1.0f / det;
		float fc0 = (fn11 * -distanceToOrigin + fn01 * other.distanceToOrigin) * invdet;
		float fc1 = (fn00 * -other.distanceToOrigin + fn01 * distanceToOrigin) * invdet;

		lineVec = normal.cross(other.normal);
		linePoint = normal * fc0 + other.normal * fc1;
		return true;
	}

	bool getIntersectionWithPlanes(Plane o1, Plane o2, Vec3f &out point)
	{
		Vec3f linePoint, lineVec;
		if (getIntersectionWithPlane(o1, linePoint, lineVec))
		{
			return o2.getIntersectionWithLine(linePoint, lineVec, point);
		}
		return false;
	}

	bool getIntersectionWithLine(Vec3f linePoint, Vec3f lineVec, Vec3f &out intersection)
	{
		float t2 = normal.dot(lineVec);

		if (t2 == 0)
		{
			return false;
		}

		float t = -(normal.dot(linePoint) + distanceToOrigin) / t2;
		intersection = linePoint + (lineVec * t);
		return true;
	}
}
