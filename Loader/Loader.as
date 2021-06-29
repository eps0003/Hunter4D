#include "LoaderCommon.as"
#include "LoadStage.as"

class Loader
{
	private LoadStage@ stage;
	private LoadStage@[] stages;
	private u8 index = 0;

	void AddStage(LoadStage@ stage)
	{
		stages.push_back(stage);

		if (stages.size() == 1)
		{
			@this.stage = stage;
			stage.Start();
		}
	}

	void Load()
	{
		if (isLoaded())
		{
			getRules().RemoveScript("LoaderHooks.as");
			print("Hunter3D loaded!", ConsoleColour::CRAZY);
			return;
		}

		stage.Load();

		if (stage.isLoaded())
		{
			stage.End();

			index++;
			if (index < stages.size())
			{
				@stage = stages[index];
				stage.Start();
			}
			else
			{
				@stage = null;
			}
		}
	}

	bool isLoaded()
	{
		return stage is null;
	}
}
