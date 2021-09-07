void onInit(CBlob@ this)
{
	this.maxChatBubbleLines = 0;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == 11 && this.getTeamNum() == getRules().getSpectatorTeamNum())
	{
		damage = 0;
	}

	return damage;
}
