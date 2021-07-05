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
		getRules().set("objects", @objects);

		object.OnInit();
		object.HandleSerializeInit(null);
	}

	void RemoveObject(u16 id)
	{
		Object@[]@ objects = Object::getObjects();
		for (uint i = 0; i < objects.size(); i++)
		{
			Object@ object = objects[i];
			if (object.id == id)
			{
				object.OnRemove();
				objects.removeAt(i);
				object.HandleSerializeRemove();
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
			Object@[] arr;
			@objects = arr;
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
			object.HandleSerializeRemove();
		}

		getRules().clear("objects");
	}
}
