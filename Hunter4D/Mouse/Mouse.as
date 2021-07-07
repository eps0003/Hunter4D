#include "MouseCommon.as"
#include "Interpolation.as"

class Mouse
{
	Vec2f velocity;
	private Vec2f _oldVelocity;
	Vec2f interVelocity;

	float sensitivity = 0.7f;

	private bool wasInControl = false;

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
		return isWindowFocused() && !isVisible() && !getRules().hasScript("LoadingScreen.as");
	}

	bool isVisible()
	{
		return Menu::getMainMenu() !is null || getHUD().hasMenus() || Engine::hasStandardGUIFocus();
	}

	private void CalculateVelocity()
	{
		_oldVelocity = velocity;

		Vec2f mousePos = getControls().getMouseScreenPos();
		Vec2f center = getDriver().getScreenCenterPos();

		velocity = Vec2f_zero;

		// Calculate velocity
		if (isInControl())
		{
			if (wasInControl)
			{
				velocity = center - mousePos;
				velocity *= sensitivity * 0.2f;

				// Recenter mouse
				if (velocity.LengthSquared() > 0)
				{
					getControls().setMousePosition(center);
				}
			}
			else
			{
				getControls().setMousePosition(center);
			}
		}

		wasInControl = isInControl();
	}

	private void UpdateVisibility()
	{
		if (isVisible())
		{
			getHUD().ShowCursor();
		}
		else
		{
			getHUD().HideCursor();
		}
	}

	void Interpolate()
	{
		float t = Interpolation::getFrameTime();
		interVelocity = Vec2f_lerp(_oldVelocity, velocity, t);
	}
}