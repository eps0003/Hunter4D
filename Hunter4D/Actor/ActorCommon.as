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

	shared Actor@ getActorByIndex(int index)
	{
		Actor@[]@ actors = Actor::getActors();
		if (index >= 0 && index < actors.size())
		{
			return actors[index];
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
					CBitStream bs;
					bs.write_u16(i);
					actor.SerializeRemove(bs);
				}

				return;
			}
		}
	}

	shared void RemoveActor(Actor@ actor)
	{
		Actor::RemoveActor(actor.getID());
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
					CBitStream bs;
					bs.write_u16(i);
					actor.SerializeRemove(bs);
				}

				return;
			}
		}
	}

	shared void RemoveActorByIndex(uint index)
	{
		Actor@ actor = Actor::getActorByIndex(index);
		if (actor is null) return;

		actor.OnRemove();

		Actor@[]@ actors = Actor::getActors();
		actors.removeAt(index);

		if (!isClient())
		{
			CBitStream bs;
			bs.write_u16(index);
			actor.SerializeRemove(bs);
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
		for (int i = actors.size() - 1; i >= 0; i--)
		{
			Actor@ actor = actors[i];
			actor.OnRemove();

			CBitStream bs;
			bs.write_u16(i);
			actor.SerializeRemove(bs);
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
