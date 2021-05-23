function edfGetElementData(theEdf, elementName)
	for i=1, #theEdf.elements do
		if (theEdf.elements[i].name == elementName) then
			return theEdf.elements[i];
		end
	end
	return false;
end

function edfIndexElementData(element)
	local data = {};
	for i=1, #element.data do
		data[element.data[i].name] = {};
		for k,v in pairs(element.data[i]) do
			if (k ~= 'name') then
				data[element.data[i].name][k] = v;
			end
		end
	end
	return data;
end

function edfGet(resourceName)
	local edf = edfGetDefinitions();
	return (edf.default.resource == resourceName) and edf.default or (edf.available.resource and edf.available.resource == resourceName) and edf.available or false;
end