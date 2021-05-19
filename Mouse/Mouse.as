#include "MouseCommon.as"

class Mouse
{
	Vec2f velocity;

	float sensitivity = 0.7f;

	private bool centerMouse = true;

	void Update()
	{
		CalculateVelocity();
		UpdateVisibility();
	}

	bool isInControl()
	{
		return isWindowFocused() && !isVisible();
	}

	bool isVisible()
	{
		return Menu::getMainMenu() !is null || getHUD().hasMenus() || Engine::hasStandardGUIFocus();
	}

	private void CalculateVelocity()
	{
		Vec2f mousePos = getControls().getMouseScreenPos();
		Vec2f center = getDriver().getScreenCenterPos();

		// Calculate velocity
		if (isInControl() && !centerMouse)
		{
			velocity = center - mousePos;
			velocity *= sensitivity * 0.2f;
		}
		else
		{
			velocity = Vec2f_zero;
		}

		// Recenter mouse
		if (velocity.LengthSquared() > 0)
		{
			getControls().setMousePosition(center);
		}

		centerMouse = !isInControl();
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
}
