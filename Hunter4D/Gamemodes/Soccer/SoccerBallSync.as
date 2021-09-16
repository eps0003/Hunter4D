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
		if (!ball.deserializeInit(params)) return;

		Object::AddObject(ball);
	}
}
