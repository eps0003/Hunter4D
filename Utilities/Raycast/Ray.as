#include "RaycastInfo.as"
#include "Blocks.as"
#include "Vec3f.as"
#include "Map.as"

class Ray
{
	Vec3f position;
	Vec3f direction;

	Ray(Vec3f position, Vec3f direction)
	{
		this.position = position;
		this.direction = direction.normalized();
	}

	// https://theshoemaker.de/2016/02/ray-casting-in-2d-grids/
	bool raycastBlock(float distance, bool solidOnly, RaycastInfo &out raycastInfo)
	{
		Map@ map = Map::getMap();
		Blocks@ blocks = Blocks::getBlocks();

		Vec3f worldPos = position.floor();

		Vec3f deltaDist(
			direction.x == 0 ? 0.0f : Maths::Abs(1.0f / direction.x),
			direction.y == 0 ? 0.0f : Maths::Abs(1.0f / direction.y),
			direction.z == 0 ? 0.0f : Maths::Abs(1.0f / direction.z)
		);

		Vec3f sideDist;
		Vec3f step;
		float dist;
		Vec3f normal;

		if (direction.x < 0)
		{
			step.x = -1;
			sideDist.x = (position.x - worldPos.x) * deltaDist.x;
		}
		else
		{
			step.x = 1;
			sideDist.x = (worldPos.x + 1.0f - position.x) * deltaDist.x;
		}

		if (direction.y < 0)
		{
			step.y = -1;
			sideDist.y = (position.y - worldPos.y) * deltaDist.y;
		}
		else
		{
			step.y = 1;
			sideDist.y = (worldPos.y + 1.0f - position.y) * deltaDist.y;
		}

		if (direction.z < 0)
		{
			step.z = -1;
			sideDist.z = (position.z - worldPos.z) * deltaDist.z;
		}
		else
		{
			step.z = 1;
			sideDist.z = (worldPos.z + 1.0f - position.z) * deltaDist.z;
		}

		while (distance > 0 && dist < distance)
		{
			SColor block = map.getBlockSafe(worldPos);

			//hit a block
			bool hit = solidOnly ? blocks.isSolid(block) : blocks.isVisible(block);
			if (hit)
			{
				dist = Maths::Max(0, dist);
				raycastInfo = RaycastInfo(this, worldPos, dist, normal);
				return true;
			}

			if (deltaDist.x != 0 && sideDist.x < sideDist.y)
			{
				if (deltaDist.z != 0 && sideDist.z < sideDist.x)
				{
					dist = sideDist.z;
					sideDist.z += deltaDist.z;
					worldPos.z += step.z;
					normal = Vec3f(0.0f, 0.0f, -step.z);
				}
				else
				{
					dist = sideDist.x;
					sideDist.x += deltaDist.x;
					worldPos.x += step.x;
					normal = Vec3f(-step.x, 0.0f, 0.0f);
				}
			}
			else
			{
				if (deltaDist.y != 0 && sideDist.y < sideDist.z)
				{
					dist = sideDist.y;
					sideDist.y += deltaDist.y;
					worldPos.y += step.y;
					normal = Vec3f(0.0f, -step.y, 0.0f);
				}
				else
				{
					dist = sideDist.z;
					sideDist.z += deltaDist.z;
					worldPos.z += step.z;
					normal = Vec3f(0.0f, 0.0f, -step.z);
				}
			}
		}

		return false;
	}
}
