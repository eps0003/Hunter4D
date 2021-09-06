#include "GunModel.as"

// https://github.com/yvt/openspades/blob/master/Sources/Client/Weapon.cpp
shared class Gun
{
	string name = "Gun";

	// Ammo
	uint clipSize = 10;
	uint stockSize = 50;

	// Shooting
	u8 pellets = 1;
	Vec3f recoil;
	float shootDelay = 0.5f;
	bool automatic = false;

	// Reloading
	bool reloadEach = false;
	float reloadTime = 1.0f;

	// Scoping
	float scopeFOV = 0.6f;
	float scopeSensitivity = 0.6f;

	float readyTime = 0.5f;

	Model@ model;

	Gun(HunterActor@ actor)
	{
		@model = GunModel(actor);
	}

	void Render()
	{
		model.Render();
	}

	uint getDamage(float distance)
	{
		return 64;
	}
}
