#include "SoccerBall.as"

void onInit(CRules@ this)
{
	this.addCommandID("init soccer ball object");
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (!isServer() && cmd == this.getCommandID("init soccer ball object"))
	{
		SoccerBall ball;
		ball.DeserializeInit(params);
		Object::AddObject(ball);
	}
}
