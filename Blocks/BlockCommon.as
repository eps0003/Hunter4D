namespace Block
{
	void LoadBlocks()
	{
		Block@[] blocks;

		ConfigFile@ cfg = ConfigFile();
		if (cfg.loadFile("Blocks.cfg"))
		{
			string[] data;
			if (cfg.readIntoArray_string(data, "blocks"))
			{
				for (uint i = 0; i < data.size(); i += 6)
				{
					string name = data[i + 0];
					bool visible = data[i + 1] == "true";
					bool solid = data[i + 2] == "true";
					bool destructible = data[i + 3] == "true";
					bool collapsible = data[i + 4] == "true";
					bool transparent = data[i + 5] == "true";

					Block block(name, visible, solid, destructible, collapsible, transparent);
					blocks.push_back(block);
					print("a");
				}
			}
		}

		getRules().set("blocks", blocks);
	}

	Block@ getBlock(uint index)
	{
		Block@[]@ blocks;
		if (getRules().get("blocks", @blocks) && index < blocks.size())
		{
			return blocks[index];
		}
		return null;
	}
}