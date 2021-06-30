#include "Loader.as"

void onInit(CRules@ this)
{
	Loader@ loader = Loader::getLoader();
	if (!this.get_bool("map generated")) loader.AddStage("GenerateMapStage.as");
	loader.AddStage("SyncMapStage.as");
	loader.NextStage();
}
