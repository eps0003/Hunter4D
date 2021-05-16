#define SERVER_ONLY

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	for (uint i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player !is null)
		{
			CreateHusk(player);
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	CreateHusk(player);
}

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	RemoveHusk(player);
}

void CreateHusk(CPlayer@ player)
{
	CBlob@ blob = server_CreateBlob("husk");
	if (blob !is null)
	{
		blob.server_SetPlayer(player);
	}
}

void RemoveHusk(CPlayer@ player)
{
	CBlob@ blob = player.getBlob();
	if (blob !is null)
	{
		blob.server_Die();
	}
}
