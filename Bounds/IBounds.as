#include "AABB.as"
#include "Map.as"
#include "CollisionFlags.as"

interface IBounds
{
	bool intersectsAABB(Vec3f thisPos, AABB other, Vec3f otherPos);
	bool intersectsPoint(Vec3f worldPos, Vec3f point);
	bool intersectsMapEdge(Vec3f worldPos);
    Vec3f getRandomPoint();
}
