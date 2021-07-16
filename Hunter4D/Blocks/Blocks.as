namespace Blocks
{
	shared bool isVisible(SColor block)
	{
		return block.getAlpha() > 0;
	}

	shared bool isSolid(SColor block)
	{
		return isVisible(block);
	}

	shared bool isDestructible(SColor block)
	{
		return true;
	}

	shared bool isCollapsible(SColor block)
	{
		return false;
	}

	shared bool isTransparent(SColor block)
	{
		return block.getAlpha() < 255;
	}
}
