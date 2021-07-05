#include "Utilities.as"

#define CLIENT_ONLY

float[] fpsArr;

void onInit(CRules@ this)
{
	onTick(this);
}

void onTick(CRules@ this)
{
	this.set_f32("inter_frame_time", 0);
	this.set_f32("inter_game_time", getGameTime());

	float fps = 0;
	uint size = fpsArr.size();
	if (size > 0)
	{
		for (uint i = 0; i < size; i++)
		{
			fps += fpsArr[i];
		}
		fps /= size;
		fpsArr.clear();
	}
	this.set_u32("fps", Maths::Round(fps));
}

void onRender(CRules@ this)
{
	if (isTickPaused()) return;

	float correction = getRenderApproximateCorrectionFactor();
	this.add_f32("inter_frame_time", correction);
	this.add_f32("inter_game_time", correction);

	fpsArr.push_back(getTicksASecond() / correction);
}
