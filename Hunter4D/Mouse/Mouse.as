#include "MouseCommon.as"
#include "Interpolation.as"
#include "Config.as"

shared class Mouse
{
	Vec2f velocity;
	private Vec2f oldVelocity;
	Vec2f interVelocity;

	private float sensitivity;

	private bool wasInControl = false;

	private CRules@ rules = getRules();
	private CControls@ controls = getControls();
	private Driver@ driver = getDriver();
	private CHUD@ hud = getHUD();

	Mouse()
	{
		ConfigFile@ cfg = Config::getConfig();
		sensitivity = cfg.read_f32("sensitivity");
	}

	void Update()
	{
		CalculateVelocity();
	}

	void Render()
	{
		UpdateVisibility();
	}

	bool isInControl()
	{
		return isWindowFocused() && !isVisible() && !rules.hasScript("LoadingScreen.as");
	}

	bool isVisible()
	{
		return Menu::getMainMenu() !is null || hud.hasMenus() || Engine::hasStandardGUIFocus();
	}

	float getSensitivity()
	{
		return sensitivity;
	}

	void SetSensitivity(float sens)
	{
		if (sensitivity == sens) return;

		sensitivity = sens;

		ConfigFile@ cfg = Config::getConfig();
		cfg.add_f32("sensitivity", sens);
		Config::SaveConfig(cfg);
	}

	private void CalculateVelocity()
	{
		oldVelocity = velocity;

		Vec2f mousePos = controls.getMouseScreenPos();
		Vec2f center = driver.getScreenCenterPos();

		velocity = Vec2f_zero;

		if (isInControl())
		{
			// Calculate velocity
			if (wasInControl)
			{
				velocity = center - mousePos - Vec2f(5, 5);
				velocity *= sensitivity * 0.15f;
			}

			// Recenter mouse
			if (!wasInControl || velocity.LengthSquared() > 0)
			{
				controls.setMousePosition(center);
			}
		}

		wasInControl = isInControl();
	}

	private void UpdateVisibility()
	{
		if (isVisible())
		{
			hud.ShowCursor();
		}
		else
		{
			hud.HideCursor();
		}
	}

	void Interpolate()
	{
		float t = Interpolation::getFrameTime();
		interVelocity = Vec2f_lerp(oldVelocity, velocity, t);
	}
}
