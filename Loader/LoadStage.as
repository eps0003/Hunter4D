class LoadStage
{
    string message;
    float progress = 0;

    LoadStage(string message)
    {
        this.message = message;
    }

    void OnStart()
    {

    }

    void Start()
    {
        progress = 0;
        OnStart();
    }

    void Load()
    {

    }

    void End()
    {

    }

    void OnEnd()
    {

    }

    bool isLoaded()
    {
        return progress >= 1;
    }
}
