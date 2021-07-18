class Command
{
	string[] aliases;
	string description;

	Command(string name, string description)
	{
		aliases.push_back(name);
		this.description = description;
	}

	void AddAlias(string name)
	{
		aliases.push_back(name);
	}

	void Execute(string[] args, CPlayer@ player) {}
}
