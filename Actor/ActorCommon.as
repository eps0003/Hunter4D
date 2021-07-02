namespace Actor
{
	Actor@ getActor(CPlayer@ player)
	{
		if (player is null) return null;

		Actor@ actor;
		player.get("actor", @actor);
		return actor;
	}

	Actor@ getMyActor()
	{
		return Actor::getActor(getLocalPlayer());
	}

	void SetActor(CPlayer@ player, Actor@ actor)
	{
		player.set("actor", @actor);
		print("Set actor: " + player.getUsername());

		if (!isClient() && actor !is null)
		{
			CBitStream bs;
			actor.SerializeInit(bs);
			getRules().SendCommand(getRules().getCommandID("init actor"), bs, true);
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

	void ClearActors()
	{
		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			Actor::SetActor(player, null);
		}
	}
}
