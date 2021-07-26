#include "Map.as"

shared class MapBuilder
{
	Map@ map;

	void Init()
	{
		@map = Map::getMap();
	}

	void Load()
	{

	}

	float getProgress()
	{
		return 0.0f;
	}

	bool isLoaded()
	{
		return false;
	}
}

shared class ConfigMap : MapBuilder
{
	private uint blocksPerSection = 5000;

	private string fileName;
	private ConfigFile cfg;
	private uint index;
	private uint needle;
	private uint size;
	private uint[] data;
	private bool encodedDamage;

	ConfigMap(string fileName)
	{
		super();
		this.fileName = "../Cache/Hunter4D/Maps/" + fileName;
	}

	void Init()
	{
		MapBuilder::Init();

		cfg.loadFile(fileName);

		index = 0;
		needle = 0;

		uint[] dimensions;
		cfg.readIntoArray_u32(dimensions, "size");
		map = Map(Vec3f(dimensions[0], dimensions[1], dimensions[2]));

		data.clear();
		cfg.readIntoArray_u32(data, "blocks");

		encodedDamage = data[0] == 1;
		data.removeAt(0);

		size = data.size();
	}

	void Load()
	{
		for (uint i = 0; i < blocksPerSection && needle < size; needle++)
		{
			uint value = data[needle];

			if (value > 0)
			{
				if (!encodedDamage)
				{
					value = (value >> 1) | (255 << 24);
				}

				map.SetBlock(index++, value);

				i++;
			}
			else
			{
				index += data[++needle] + 1;
			}
		}
	}

	float getProgress()
	{
		return needle / Maths::Max(1, size);
	}

	bool isLoaded()
	{
		return needle >= size;
	}
}

shared class MapGenerator : MapBuilder
{
	Random@ random;

	MapGenerator(uint seed)
	{
		super();
		@random = Random(seed);
	}

	void Init()
	{
		map = Map(Vec3f(16, 8, 16));
	}

	void Load()
	{
		for (uint x = 0; x < map.dimensions.x; x++)
		for (uint z = 0; z < map.dimensions.z; z++)
		{
			map.SetBlock(x, 0, z, SColor(255, 100, 100, 100));
		}
	}

	float getProgress()
	{
		return 0.0f;
	}

	bool isLoaded()
	{
		return true;
	}
}
