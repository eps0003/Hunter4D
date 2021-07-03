#include "BlocksCommon.as"

class Blocks
{
	private string[] name;
	private bool[] visible;
	private bool[] solid;
	private bool[] destructible;
	private bool[] collapsible;
	private bool[] transparent;

	void AddBlock(string name, bool visible, bool solid, bool destructible, bool collapsible, bool transparent)
	{
		this.name.push_back(name);
		this.visible.push_back(visible);
		this.solid.push_back(solid);
		this.destructible.push_back(destructible);
		this.collapsible.push_back(collapsible);
		this.transparent.push_back(transparent);
	}

	string getName(SColor block)
	{
		return "";
	}

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
