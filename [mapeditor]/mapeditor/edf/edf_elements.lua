edfElements = {};

------------------
--	OBJECT
------------------
edfElements.object = {};
edfElements.object.properties = {};
edfElements.object.properties.model = {
	type = "string",
	getValue = function(element)
		return GetEntityModel(element);
	end,
	applier = function()
		return false;-- no applier
	end
};
edfElements.object.properties.position = {
	type = "coord3d",
	getValue = function(element)
		local elementCoord = GetEntityCoords(element);
		return {elementCoord.x, elementCoord.y, elementCoord.z};
	end,
	applier = function(element, value)
		SetEntityCoords(element, vector3(value[1], value[2], value[3]));
	end
};
edfElements.object.properties.rotation = {
	type = "coord3d",
	getValue = function(element)
		local elementRotation = GetEntityRotation(element);
		return {elementRotation.x, elementRotation.y, elementRotation.z};
	end,
	applier = function(element, value)
		SetEntityRotation(element, vector3(value[1], value[2], value[3]), 2);
	end
};


------------------
--	VEHICLE
------------------
edfElements.vehicle = {};
edfElements.vehicle.properties = {};
edfElements.vehicle.properties.model = {
	type = "string",
	getValue = function(element)
		return GetEntityModel(element);
	end,
	applier = function()
		return false;-- no applier
	end
};
edfElements.vehicle.properties.position = {
	type = "coord3d",
	getValue = function(element)
		local elementCoord = GetEntityCoords(element);
		return {elementCoord.x, elementCoord.y, elementCoord.z};
	end,
	applier = function(element, value)
		SetEntityCoords(element, vector3(value[1], value[2], value[3]));
	end
};
edfElements.vehicle.properties.rotation = {
	type = "coord3d",
	getValue = function(element)
		local elementRotation = GetEntityRotation(element);
		return {elementRotation.x, elementRotation.y, elementRotation.z};
	end,
	applier = function(element, value)
		SetEntityRotation(element, vector3(value[1], value[2], value[3]), 2);
	end
};