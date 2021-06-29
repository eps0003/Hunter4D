#include "Loader.as"

void onInit(CRules@ this)
{
	Loader@ loader = Loader::getLoader();
	if (isClient()) loader.AddStage("DeserializeMapStage.as");
	loader.NextStage();
}
