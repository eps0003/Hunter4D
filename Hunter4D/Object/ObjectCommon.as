namespace Object
{
	shared Object@ getObject(u16 id)
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

	shared Object@ getObjectByIndex(int index)
	{
		Object@[]@ objects = Object::getObjects();
		if (index >= 0 && index < objects.size())
		{
			return objects[index];
		}
		return null;
	}

	shared void AddObject(Object@ object)
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

	shared void RemoveObject(Object@ object)
	{
		Object::RemoveObject(object.getID());
	}

	shared void RemoveObject(u16 id)
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
					CBitStream bs;
					bs.write_u16(i);
					object.SerializeRemove(bs);
				}

				return;
			}
		}
	}

	shared void RemoveObjectByIndex(uint index)
	{
		Object@ object = Object::getObjectByIndex(index);
		if (object is null) return;

		object.OnRemove();

		Object@[]@ objects = Object::getObjects();
		objects.removeAt(index);

		if (!isClient())
		{
			CBitStream bs;
			bs.write_u16(index);
			object.SerializeRemove(bs);
		}
	}

	shared bool objectExists(u16 id)
	{
		return Object::getObject(id) !is null;
	}

	shared Object@[]@ getObjects()
	{
		Object@[]@ objects;
		if (!getRules().get("objects", @objects))
		{
			@objects = array<Object@>();
			getRules().set("objects", @objects);
		}
		return objects;
	}

	shared uint getObjectCount()
	{
		return Object::getObjects().size();
	}

	shared uint getVisibleObjectCount()
	{
		uint count = 0;

		Object@[]@ objects = Object::getObjects();
		for (uint i = 0; i < objects.size(); i++)
		{
			Object@ object = objects[i];
			if (object.isVisible())
			{
				count++;
			}
		}

		return count;
	}

	shared void ClearObjects()
	{
		Object@[]@ objects = Object::getObjects();
		for (int i = objects.size() - 1; i >= 0; i--)
		{
			Object@ object = objects[i];
			object.OnRemove();

			CBitStream bs;
			bs.write_u16(i);
			object.SerializeRemove(bs);
		}
		getRules().clear("objects");
	}

	shared bool saferead(CBitStream@ bs, Object@ &out object)
	{
		u16 id;
		if (!bs.saferead_u16(id)) return false;

		@object = Object::getObject(id);
		return object !is null;
	}
}
