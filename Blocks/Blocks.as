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

    string getName(u8 block)
	{
		return name[block];
	}

	bool isVisible(u8 block)
	{
		return visible[block];
	}

	bool isSolid(u8 block)
	{
		return solid[block];
	}

	bool isDestructible(u8 block)
	{
		return destructible[block];
	}

	bool isCollapsible(u8 block)
	{
		return collapsible[block];
	}

	bool isTransparent(u8 block)
	{
		return transparent[block];
	}
}
