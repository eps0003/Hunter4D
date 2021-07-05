namespace Actor
{
	Actor@ getActor(CPlayer@ player)
	{
		Actor@ actor;
		if (player !is null)
		{
			player.get("actor", @actor);
		}
		return actor;
	}

	Actor@ getMyActor()
	{
		return Actor::getActor(getLocalPlayer());
	}

	void AddActor(Actor@ actor)
	{
		Object::AddObject(actor);
		actor.player.set("actor", @actor);
	}

	void RemoveActor(CPlayer@ player)
	{
		Actor@ actor = Actor::getActor(player);
		if (actor !is null)
		{
			Object::RemoveObject(actor.id);
			player.set("actor", null);
		}
	}

	bool hasActor(CPlayer@ player)
	{
		return Actor::getActor(player) !is null;
	}

	Actor@[] getActors()
	{
		Actor@[] actors;

		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			Actor@ actor = Actor::getActor(player);

			if (actor !is null)
			{
				actors.push_back(actor);
			}
		}

		return actors;
	}

	uint getActorCount()
	{
		return Actor::getActors().size();
	}
}
