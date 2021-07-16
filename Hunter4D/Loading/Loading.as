namespace Loading
{
	shared bool isPlayerLoaded(CPlayer@ player)
	{
		return getRules().get_bool(player.getUsername() + "loaded");
	}

	shared bool isMyPlayerLoaded()
	{
		return isPlayerLoaded(getLocalPlayer());
	}

	shared void SetPlayerLoaded(CPlayer@ player, bool loaded)
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

	shared void SetMyPlayerLoaded(bool loaded)
	{
		SetPlayerLoaded(getLocalPlayer(), loaded);
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
}
