namespace Actor
{
	Actor@ getActor(CPlayer@ player)
	{
		Actor@[]@ actors = Actor::getActors();
		for (uint i = 0; i < actors.size(); i++)
		{
			Actor@ actor = actors[i];
			if (actor.getPlayer() is player)
			{
				return actor;
			}
		}
		return null;
	}

	Actor@ getMyActor()
	{
		return Actor::getActor(getLocalPlayer());
	}

	void AddActor(Actor@ actor)
	{
		Actor@[]@ actors = Actor::getActors();
		actors.push_back(actor);
		getRules().set("actors", @actors);

		actor.OnInit();

		if (!isClient())
		{
			actor.SerializeInit(null);
		}
	}

	void RemoveActor(CPlayer@ player)
	{
		Actor@[]@ actors = Actor::getActors();
		for (uint i = 0; i < actors.size(); i++)
		{
			Actor@ actor = actors[i];
			if (actor.getPlayer() is player)
			{
				actor.OnRemove();
				actors.removeAt(i);

				if (!isClient())
				{
					actor.SerializeRemove();
				}

				return;
			}
		}
	}

	bool actorExists(CPlayer@ player)
	{
		return Actor::getActor(player) !is null;
	}

	Actor@[]@ getActors()
	{
		Actor@[]@ actors;
		if (!getRules().get("actors", @actors))
		{
			@actors = array<Actor@>();
			getRules().set("actors", @actors);
		}
		return actors;
	}

	uint getActorCount()
	{
		return Actor::getActors().size();
	}

	void ClearActors()
	{
		Actor@[]@ actors = Actor::getActors();
		for (uint i = 0; i < actors.size(); i++)
		{
			Actor@ actor = actors[i];
			actor.OnRemove();
			actor.SerializeRemove();
		}
		getRules().clear("actors");
	}
}
