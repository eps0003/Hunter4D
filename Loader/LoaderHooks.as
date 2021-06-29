#include "Loader.as"
#include "DeserializeMapStage.as"

void onInit(CRules@ this)
{
	Loader@ loader = Loader::getLoader();
	if (isClient()) loader.AddStage(DeserializeMapStage());
}

void onTick(CRules@ this)
{
	Loader::getLoader().Load();
}