namespace Loading
{
	bool isPlayerLoaded(CPlayer@ player)
	{
		return getRules().get_bool(player.getUsername() + "loaded");
	}

	bool isMyPlayerLoaded()
	{
		return isPlayerLoaded(getLocalPlayer());
	}

	void SetPlayerLoaded(CPlayer@ player, bool loaded)
	{
		if (loaded == isPlayerLoaded(player)) return;

		string token = player.getUsername() + "loaded";
		getRules().set_bool(token, loaded);
		getRules().Sync(token, true);

		if (loaded && player.isMyPlayer())
		{
			CBitStream bs;
			bs.write_netid(player.getNetworkID());
			getRules().SendCommand(getRules().getCommandID("player loaded"), bs, false);
		}
	}

	void SetMyPlayerLoaded(bool loaded)
	{
		SetPlayerLoaded(getLocalPlayer(), loaded);
	}

	bool areAllPlayersLoaded()
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

	void SetAllPlayersLoaded(bool loaded)
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
}
