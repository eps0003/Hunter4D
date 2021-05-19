#include "MouseCommon.as"

class Mouse
{
	Vec2f velocity;

	float sensitivity = 0.7f;

	private bool wasInControl = false;

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
}
