shared interface IBounds
{
	bool intersectsAABB(Vec3f thisPos, AABB other, Vec3f otherPos);
	bool intersectsPoint(Vec3f worldPos, Vec3f point);
	bool intersectsNewSolid(Vec3f currentPos, Vec3f worldPos);
	bool intersectsVoxel(Vec3f worldPos, Vec3f voxelWorldPos);
	bool intersectsMapEdge(Vec3f worldPos);
	Vec3f getRandomPoint();
}
