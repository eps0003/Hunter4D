namespace Actor
{
	shared Actor@ getActor(CPlayer@ player)
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

	shared Actor@ getActor(u16 id)
	{
		Actor@[]@ actors = Actor::getActors();
		for (uint i = 0; i < actors.size(); i++)
		{
			Actor@ actor = actors[i];
			if (actor.getID() == id)
			{
				return actor;
			}
		}
		return null;
	}

	shared Actor@ getMyActor()
	{
		return Actor::getActor(getLocalPlayer());
	}

	shared void AddActor(Actor@ actor)
	{
		Actor::RemoveActor(actor.getPlayer());

		Actor@[]@ actors = Actor::getActors();
		actors.push_back(actor);
		getRules().set("actors", @actors);

		actor.OnInit();

		if (!isClient())
		{
			actor.SerializeInit();
		}
	}

	shared void RemoveActor(CPlayer@ player)
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

	shared void RemoveActor(u16 id)
	{
		Actor@[]@ actors = Actor::getActors();
		for (uint i = 0; i < actors.size(); i++)
		{
			Actor@ actor = actors[i];
			if (actor.getID() == id)
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

	shared bool actorExists(u16 id)
	{
		return Actor::getActor(id) !is null;
	}

	shared bool actorExists(CPlayer@ player)
	{
		return Actor::getActor(player) !is null;
	}

	shared Actor@[]@ getActors()
	{
		Actor@[]@ actors;
		if (!getRules().get("actors", @actors))
		{
			@actors = array<Actor@>();
			getRules().set("actors", @actors);
		}
		return actors;
	}

	shared uint getActorCount()
	{
		return Actor::getActors().size();
	}

	shared uint getVisibleActorCount()
	{
		uint count = 0;

		Actor@[]@ actors = Actor::getActors();
		for (uint i = 0; i < actors.size(); i++)
		{
			Actor@ actor = actors[i];
			if (actor.isVisible())
			{
				count++;
			}
		}

		return count;
	}

	shared void ClearActors()
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

	shared bool saferead(CBitStream@ bs, Actor@ &out actor)
	{
		u16 id;
		if (!bs.saferead_u16(id)) return false;

		@actor = Actor::getActor(id);
		return actor !is null;
	}
}
