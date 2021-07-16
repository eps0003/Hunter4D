shared class MapRequest
{
	CPlayer@ player;
	u16 packet;

	MapRequest(CPlayer@ player, u16 packet = 0)
	{
		@this.player = player;
		this.packet = packet;
	}
}
