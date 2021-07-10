namespace Particles
{
	ParticleManager@ getManager()
	{
		ParticleManager@ manager;
		if (!getRules().get("particle manager", @manager))
		{
			@manager = ParticleManager();
			getRules().set("particle manager", @manager);
		}
		return manager;
	}
}
