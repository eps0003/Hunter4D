#include "Loader.as"

void onInit(CRules@ this)
{
	Loader@ loader = Loader::getLoader();
	loader.AddStage("GenerateMapStage.as");
	if (isClient()) loader.AddStage("DeserializeMapStage.as");
	loader.NextStage();
}
