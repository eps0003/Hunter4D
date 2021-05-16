namespace Object
{
    Object@ getObject(CPlayer@ player)
    {
        if (player is null) return null;

        Object@ object;
        player.get("object", @object);
        return object;
    }

    Object@ getMyObject()
    {
        return Object::getObject(getLocalPlayer());
    }

    void SetObject(CPlayer@ player, Object@ object)
    {
        player.set("object", @object);
    }

    bool hasObject(CPlayer@ player)
    {
        return Object::getObject(player) !is null;
    }

    Object@[] getObjects()
    {
        Object@[] objects;

        for (uint i = 0; i < getPlayerCount(); i++)
        {
            CPlayer@ player = getPlayer(i);
            Object@ object = Object::getObject(player);

            if (object !is null)
            {
                objects.push_back(object);
            }
        }

        return objects;
    }

    uint getObjectCount()
    {
        return Object::getObjects().size();
    }

    void ClearObjects()
    {
        for (uint i = 0; i < getPlayerCount(); i++)
        {
            CPlayer@ player = getPlayer(i);
            Object::SetObject(player, null);
        }
    }
}
