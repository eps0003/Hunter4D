#include "Loader.as"

void onTick(CRules@ this)
{
	Loader::getLoader().Load();
}