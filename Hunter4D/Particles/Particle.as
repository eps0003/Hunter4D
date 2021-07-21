#include "ParticleCommon.as"
#include "Map.as"
#include "Camera.as"

shared class Particle
{
	Vec3f position;
	Vec3f velocity;
	SColor color = color_white;
	u16 timeToLive = 2 * getTicksASecond();
	bool dieOnCollide = false;
	float gravity = 0.0f;
	float elasticity = 0.0f;
	float friction = 1.0f;
}

shared class ParticleManager
{
	private uint count = 0;
	private uint maxParticles = 300;
	private float maxDistance = 30.0f;

	private Vec3f[] position;
	private Vec3f[] oldPosition;

	private Vec3f[] velocity;

	private SColor[] color;

	private bool[] static;

	private uint[] spawnTime;
	private u16[] timeToLive;

	private bool[] dieOnCollide;

	private float[] gravity;
	private float[] elasticity;
	private float[] friction;

	private float maxScale = 0.0625f;

	private float[] matrix;

	private CRules@ rules = getRules();
	private Map@ map = Map::getMap();
	private Camera@ camera = Camera::getCamera();

	ParticleManager()
	{
		Matrix::MakeIdentity(matrix);
	}

	void Update()
	{
		if (v_fastrender)
		{
			ClearParticles();
			return;
		}

		uint gameTime = getGameTime();

		for (int i = count - 1; i >= 0; i--)
		{
			float dist = (camera.position - position[i]).magSquared();
			if (position[i].y <= -10 || dist >= maxDistance * maxDistance || gameTime >= spawnTime[i] + timeToLive[i])
			{
				RemoveParticle(i);
				continue;
			}

			oldPosition[i] = position[i];

			if (static[i]) continue;

			velocity[i].y = Maths::Clamp(velocity[i].y + gravity[i], -1, 1);

			position[i] += velocity[i];

			Vec3f opf = oldPosition[i].floor();
			Vec3f pf = position[i].floor();
			if (opf != pf && map.isSolid(map.getBlockSafe(pf)))
			{
				if (dieOnCollide[i])
				{
					RemoveParticle(i);
					continue;
				}

				if (opf.y != pf.y)
				{
					//prevent particle from phasing through voxel
					if (velocity[i].y < 0)
					{
						position[i].y = Maths::Ceil(position[i].y);

						velocity[i].x *= friction[i];
						velocity[i].z *= friction[i];

						if ((velocity[i] - Vec3f(0, gravity[i], 0)).magSquared() < 0.001f)
						{
							static[i] = true;
							velocity[i].Clear();
							continue;
						}
					}
					else if (velocity[i].y > 0)
					{
						position[i].y = Maths::Floor(position[i].y);
					}

					velocity[i].y *= -elasticity[i];
				}

				if (opf.x != pf.x)
				{
					if (velocity[i].x < 0)
					{
						position[i].x = Maths::Ceil(position[i].x);
					}
					else if (velocity[i].x > 0)
					{
						position[i].x = Maths::Floor(position[i].x);
					}

					velocity[i].x *= -elasticity[i];
				}

				if (opf.z != pf.z)
				{
					if (velocity[i].z < 0)
					{
						position[i].z = Maths::Ceil(position[i].z);
					}
					else if (velocity[i].x > 0)
					{
						position[i].z = Maths::Floor(position[i].z);
					}

					velocity[i].z *= -elasticity[i];
				}
			}
		}
	}

	void AddParticle(Particle particle)
	{
		if (v_fastrender) return;

		float dist = (camera.position - particle.position).magSquared();
		if (dist >= maxDistance * maxDistance) return;

		if (count >= maxParticles)
		{
			RemoveParticle(0);
		}

		position.push_back(particle.position);
		oldPosition.push_back(particle.position);

		velocity.push_back(particle.velocity);

		color.push_back(particle.color);

		spawnTime.push_back(getGameTime());
		timeToLive.push_back(particle.timeToLive);

		dieOnCollide.push_back(particle.dieOnCollide);
		gravity.push_back(particle.gravity);
		elasticity.push_back(particle.elasticity);
		friction.push_back(particle.friction);

		static.push_back(particle.velocity.magSquared() == 0 && particle.gravity == 0);

		count++;
	}

	void RemoveParticle(uint index)
	{
		position.removeAt(index);
		oldPosition.removeAt(index);

		velocity.removeAt(index);

		color.removeAt(index);

		static.removeAt(index);

		spawnTime.removeAt(index);
		timeToLive.removeAt(index);

		dieOnCollide.removeAt(index);
		gravity.removeAt(index);
		elasticity.removeAt(index);
		friction.removeAt(index);

		count--;
	}

	void ClearParticles()
	{
		if (count == 0) return;

		position.clear();
		oldPosition.clear();

		velocity.clear();

		color.clear();

		static.clear();

		spawnTime.clear();
		timeToLive.clear();

		dieOnCollide.clear();
		gravity.clear();
		elasticity.clear();
		friction.clear();

		count = 0;
	}

	void Render()
	{
		if (count == 0) return;

		Render::SetModelTransform(matrix);

		float t = Interpolation::getFrameTime();
		float gt = Interpolation::getGameTime();

		float yRotationRadians = Maths::toRadians(camera.interRotation.y);
		Vec3f vec(Maths::FastCos(yRotationRadians), 1, Maths::FastSin(yRotationRadians));

		Vertex[] vertices = array<Vertex>(count * 4);

		for (uint i = 0; i < count; i++)
		{
			uint index = i * 4;

			Vec3f pos = static[i] ? position[i] : oldPosition[i].lerp(position[i], t);
			SColor col = color[i];

			float time = (gt - spawnTime[i]) / timeToLive[i];
			float scale = maxScale * (1 - Maths::Pow(time, 10));

			vertices[index + 0] = Vertex(pos.x - scale * vec.x, pos.y - scale * vec.y, pos.z - scale * vec.z, 0, 1, col);
			vertices[index + 1] = Vertex(pos.x - scale * vec.x, pos.y + scale * vec.y, pos.z - scale * vec.z, 0, 0, col);
			vertices[index + 2] = Vertex(pos.x + scale * vec.x, pos.y + scale * vec.y, pos.z + scale * vec.z, 1, 0, col);
			vertices[index + 3] = Vertex(pos.x + scale * vec.x, pos.y - scale * vec.y, pos.z + scale * vec.z, 1, 1, col);
		}

		Render::RawQuads("pixel", vertices);
	}

	void CheckStaticParticles()
	{
		for (uint i = 0; i < count; i++)
		{
			if (!static[i] || gravity[i] == 0.0f) continue;

			Vec3f pos = position[i] - Vec3f(0, gravity[i], 0);
			if (!map.isSolid(map.getBlockSafe(pos)))
			{
				static[i] = false;
			}
		}
	}

	uint getParticleCount()
	{
		return count;
	}
}
