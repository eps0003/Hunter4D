namespace Object
{
    Object@ getObject(u16 id)
    {
        Object@[]@ objects = Object::getObjects();

        for (uint i = 0; i < objects.size(); i++)
        {
            Object@ object = objects[i];
            if (object.id == id)
            {
                return object;
            }
        }

        return null;
    }

    void AddObject(Object@ object)
    {
        Object@[]@ objects = Object::getObjects();
        objects.push_back(object);

        print("Added object: " + object.id);

        if (!isClient())
        {
            CBitStream bs;
            object.SerializeInit(bs);
            getRules().SendCommand(getRules().getCommandID("init object"), bs, true);
        }
    }

    bool objectExists(u16 id)
    {
        return Object::getObject(id) !is null;
    }

    Object@[]@ getObjects()
    {
        CRules@ rules = getRules();

        if (!rules.exists("objects"))
        {
            Object@[] objects;
            rules.set("objects", @objects);
        }

        Object@[]@ objects;
        rules.get("objects", @objects);
        return objects;
    }

    uint getObjectCount()
    {
        return Object::getObjects().size();
    }

    void ClearObjects()
    {
        getRules().clear("objects");
    }
}
