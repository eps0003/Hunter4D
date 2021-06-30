#include "LoaderCommon.as"

class Loader
{
	private CRules@ rules;
	private string[] stages;
	private int index = -1;

	Loader()
	{
		@rules = getRules();
	}

	void AddStage(string stage)
	{
		stages.push_back(stage);
	}

	void NextStage()
	{
		if (index > -1)
		{
			rules.RemoveScript(stages[index]);
		}

		if (index < stages.size())
		{
			index++;
			if (index < stages.size())
			{
				rules.AddScript(stages[index]);
			}
			else
			{
				print("Hunter3D loaded!", ConsoleColour::CRAZY);
			}
		}
	}

	bool isLoaded()
	{
		return stages.size() == 0 || index >= stages.size();
	}
}
