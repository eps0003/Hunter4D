#define CLIENT_ONLY

Driver@ driver;

void onInit(CRules@ this)
{
	@driver = getDriver();

	int id = Render::addScript(Render::layer_posthud, "LoadingScreen.as", "Render", 0);
	this.set_s32("loading screen id", id);
}

void Render(int id)
{
	// Background colour
	Vec2f screenDim = driver.getScreenDimensions();
	SColor color(255, 165, 189, 200);
	GUI::DrawRectangle(Vec2f_zero, screenDim, color);

	DrawLoadingBar(getRules());
}

void DrawLoadingBar(CRules@ this)
{
	Vec2f center = driver.getScreenCenterPos();
	uint halfWidth = getScreenWidth() * 0.4f;

	string text = this.get_string("loading message");
	float progress = Maths::Clamp01(this.get_f32("loading progress"));

	Vec2f textDim;
	GUI::GetTextDimensions(text, textDim);

	Vec2f tl(center.x - halfWidth, center.y - textDim.y);
	Vec2f br(center.x + halfWidth, center.y + textDim.y);

	GUI::DrawProgressBar(tl, br, progress);
	GUI::DrawTextCentered(text, center, color_white);
}
