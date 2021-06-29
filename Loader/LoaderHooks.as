#include "Loader.as"

void onInit(CRules@ this)
{
	Loader@ loader = Loader::getLoader();
	loader.AddStage("GenerateMapStage.as");
	if (isClient() != isServer()) loader.AddStage("SyncMapStage.as");
	loader.NextStage();
}
