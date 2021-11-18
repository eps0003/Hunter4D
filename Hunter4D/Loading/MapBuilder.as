#include "Map.as"
#include "Utilities.as"

shared class MapBuilder
{
	string name;
	Map@ map;

	MapBuilder(string name)
	{
		this.name = name;
	}

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

	private SColor fillerBlockColor = SColor(255, 103, 64, 30);

	private uint i;
	private uint value;
	private float progressDen;

	ConfigMap(string fileName)
	{
		super(trimFileExtension(fileName));
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

		size = data.size();
		progressDen = Maths::Max(1, size);
	}

	void Load()
	{
		for (i = 0; i < blocksPerSection && needle < size; needle++)
		{
			value = data[needle];

			// Is visible
			if (value & 1 == 1)
			{
				// Is filler block
				if (value & 2 == 2)
				{
					map.SetBlock(index++, fillerBlockColor);
				}
				else
				{
					map.SetBlock(index++, (value >> 2) | 4278190080); // 255 << 24 == 4278190080
				}

				i++;
			}
			else
			{
				index += (value >> 1) + 1;
			}
		}
	}

	float getProgress()
	{
		return needle / progressDen;
	}

	bool isLoaded()
	{
		return needle >= size;
	}
}

shared class MapGenerator : MapBuilder
{
	Vec3f dimensions;

	MapGenerator(string name, Vec3f dimensions)
	{
		super(name);
		this.dimensions = dimensions;
	}

	void Init()
	{
		MapBuilder::Init();
		map = Map(dimensions);
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
