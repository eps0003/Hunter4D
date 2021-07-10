#include "Particle.as"

#define CLIENT_ONLY

ParticleManager@ manager;

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	@manager = Particles::getManager();
}

void onTick(CRules@ this)
{
	manager.Update();
}
