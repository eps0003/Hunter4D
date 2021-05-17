#include "BlockCommon.as"

class Block
{
	string name;
	bool visible;
	bool solid;
	bool destructible;
	bool collapsible;
	bool transparent;

	Block(string name, bool visible, bool solid, bool destructible, bool collapsible, bool transparent)
	{
		this.name = name;
		this.visible = visible;
		this.solid = solid;
		this.destructible = destructible;
		this.collapsible = collapsible;
		this.transparent = transparent;
	}
}
