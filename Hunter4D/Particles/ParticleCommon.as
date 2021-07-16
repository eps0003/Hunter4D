namespace Particles
{
	shared ParticleManager@ getManager()
	{
		ParticleManager@ manager;
		if (!getRules().get("particle manager", @manager))
		{
			@manager = ParticleManager();
			getRules().set("particle manager", @manager);
		}
		return manager;
	}

	shared void EmitBlockBreakParticles(int index, SColor block)
	{
		ParticleManager@ particleManager = Particles::getManager();
		Map@ map = Map::getMap();

		Vec3f position = map.indexToPos(index);
		AABB bounds(position, position + 1);
		Random random(getGameTime());

		for (uint i = 0; i < 20; i++)
		{
			Vec3f pos = bounds.getRandomPoint();

			Vec3f dir = pos - (position + 0.5f);
			Vec3f vel(dir, random.NextFloat() * 0.2f);
			vel.y = Maths::Max(0, vel.y);
			vel.x *= 0.5f;
			vel.z *= 0.5f;

			Particle particle;
			particle.position = pos;
			particle.velocity = vel;
			particle.timeToLive = 40 + random.NextRanged(60);
			particle.color.setRed(block.getRed() * 0.8f);
			particle.color.setGreen(block.getGreen() * 0.8f);
			particle.color.setBlue(block.getBlue() * 0.8f);
			particle.gravity = -0.03f;
			particle.elasticity = 0.5f;
			particle.friction = 0.6f;

			particleManager.AddParticle(particle);
		}
	}
}
