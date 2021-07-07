#include "Actor.as"

void onInit(CRules@ this)
{
	this.addCommandID("change color");
}

void onTick(CRules@ this)
{
	if (isClient())
	{
		if (getControls().isKeyJustPressed(KEY_LBUTTON))
		{
			if (isServer())
			{
				ChangeColor(Actor::getActor(getLocalPlayer()));
			}
			else
			{
				CBitStream bs;
				bs.write_netid(getLocalPlayer().getNetworkID());
				this.SendCommand(this.getCommandID("change color"), bs, false);
			}
		}
	}
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (isServer())
	{
		if (cmd == this.getCommandID("change color"))
		{
			u16 playerId;
			if (!params.saferead_netid(playerId)) return;

			CPlayer@ player = getPlayerByNetworkId(playerId);
			Actor@ actor = Actor::getActor(player);

			ChangeColor(actor);
		}
	}
}

void ChangeColor(Object@ object)
{
	if (object !is null)
	{
		object.color = SColor(255, XORRandom(255), XORRandom(255), XORRandom(255));
	}
}
