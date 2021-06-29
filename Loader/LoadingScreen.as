#include "Loader.as"

#define CLIENT_ONLY

Loader@ loader;
Driver@ driver;

void onInit(CRules@ this)
{
	@loader = Loader::getLoader();
	@driver = getDriver();
}

void onRender(CRules@ this)
{
	if (loader.isLoaded())
	{
		this.RemoveScript(getCurrentScriptName());
		return;
	}

	//background colour
	Vec2f screenDim = driver.getScreenDimensions();
	SColor color(255, 165, 189, 200);
	GUI::DrawRectangle(Vec2f_zero, screenDim, color);

	DrawLoadingBar(this);
}

void DrawLoadingBar(CRules@ this)
{
	Vec2f dim = driver.getScreenDimensions();
	Vec2f center = driver.getScreenCenterPos();

	uint halfWidth = (dim.x * 0.8f) / 2.0f;

	string text = this.get_string("loading message");
	float progress = Maths::Clamp01(this.get_f32("loading progress"));

	Vec2f textDim;
	GUI::GetTextDimensions(text, textDim);

	Vec2f tl(center.x - halfWidth, center.y - textDim.y);
	Vec2f br(center.x + halfWidth, center.y + textDim.y);

	GUI::DrawProgressBar(tl, br, progress);
	GUI::DrawTextCentered(text, center, color_white);
}
