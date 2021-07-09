namespace Object
{
	Object@ getObject(u16 id)
	{
		Object@[]@ objects = Object::getObjects();
		for (uint i = 0; i < objects.size(); i++)
		{
			Object@ object = objects[i];
			if (object.getID() == id)
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
		getRules().set("objects", @objects);

		object.OnInit();

		if (!isClient())
		{
			object.SerializeInit();
		}
	}

	void RemoveObject(u16 id)
	{
		Object@[]@ objects = Object::getObjects();
		for (uint i = 0; i < objects.size(); i++)
		{
			Object@ object = objects[i];
			if (object.getID() == id)
			{
				object.OnRemove();
				objects.removeAt(i);

				if (!isClient())
				{
					object.SerializeRemove();
				}

				return;
			}
		}
	}

	bool objectExists(u16 id)
	{
		return Object::getObject(id) !is null;
	}

	Object@[]@ getObjects()
	{
		Object@[]@ objects;
		if (!getRules().get("objects", @objects))
		{
			@objects = array<Object@>();
			getRules().set("objects", @objects);
		}
		return objects;
	}

	uint getObjectCount()
	{
		return Object::getObjects().size();
	}

	void ClearObjects()
	{
		Object@[]@ objects = Object::getObjects();
		for (uint i = 0; i < objects.size(); i++)
		{
			Object@ object = objects[i];
			object.OnRemove();
			object.SerializeRemove();
		}
		getRules().clear("objects");
	}
}
