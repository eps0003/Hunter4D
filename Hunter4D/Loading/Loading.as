namespace Loading
{
	shared bool isPlayerLoaded(CPlayer@ player)
	{
		return getRules().get_bool(player.getNetworkID() + "loaded");
	}

	shared bool isMyPlayerLoaded()
	{
		return isPlayerLoaded(getLocalPlayer());
	}

	shared void SetPlayerLoaded(CPlayer@ player, bool loaded)
	{
		if (loaded == isPlayerLoaded(player)) return;

		CRules@ rules = getRules();
		string token = player.getNetworkID() + "loaded";

		rules.set_bool(token, loaded);
		rules.Sync(token, true);

		if (loaded && player.isMyPlayer())
		{
			CBitStream bs;
			bs.write_netid(player.getNetworkID());
			rules.SendCommand(rules.getCommandID("player loaded"), bs, false);
		}
	}

	shared void SetMyPlayerLoaded(bool loaded)
	{
		SetPlayerLoaded(getLocalPlayer(), loaded);

		if (loaded)
		{
			int id = getRules().get_s32("loading screen id");
			Render::RemoveScript(id);
		}
	}

	shared void SetAllPlayersLoaded(bool loaded)
	{
		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player !is null)
			{
				SetPlayerLoaded(player, loaded);
			}
		}
	}

	shared bool areAllPlayersLoaded()
	{
		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player !is null && !isPlayerLoaded(player))
			{
				return false;
			}
		}
		return true;
	}

	shared bool areAnyPlayersLoaded()
	{
		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player !is null && isPlayerLoaded(player))
			{
				return true;
			}
		}
		return false;
	}

	shared uint getLoadedPlayerCount()
	{
		uint count = 0;
		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player !is null && isPlayerLoaded(player))
			{
				count++;
			}
		}
		return count;
	}
}
