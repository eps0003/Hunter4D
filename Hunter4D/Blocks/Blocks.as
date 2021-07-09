namespace Blocks
{
	bool isVisible(SColor block)
	{
		return block.getAlpha() > 0;
	}

	bool isSolid(SColor block)
	{
		return isVisible(block);
	}

	bool isDestructible(SColor block)
	{
		return true;
	}

	bool isCollapsible(SColor block)
	{
		return false;
	}

	bool isTransparent(SColor block)
	{
		return block.getAlpha() < 255;
	}
}
