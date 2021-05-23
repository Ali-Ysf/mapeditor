elementProprties = {};
elementProprties.enabled = false;

local function restoreElementProperties()
	local elementData = elementProprties.elementData.edfData;
	for k,v in ipairs(elementData.data) do
		if (edfElements[elementData.type].properties[v.name]) then
			if (edfElements[elementData.type].properties[v.name].applier and elementProprties.elementData.defaultValues[v.name]) then
				edfElements[elementData.type].properties[v.name].applier(elementProprties.elementData.element, elementProprties.elementData.defaultValues[v.name]);
			end
		end
	end
end

function openElementProperties(element, elementData)
	elementProprties.enabled = true;
	elementProprties.elementData = {
		element = element,
		edfData = elementData,
		defaultValues = {}
	};

	local tempTable = {};
	for k,v in ipairs(elementData.data) do
		if (edfElements[elementData.type].properties[v.name]) then
			local data = edfElements[elementData.type].properties[v.name];
			elementProprties.elementData.defaultValues[v.name] = data.getValue(elementProprties.elementData.element);
			
			table.insert(tempTable, {
				name = v.name,
				type = data.type,
				disabled = v.disabled,
				value = elementProprties.elementData.defaultValues[v.name]
			});
		end
	end
	
	--mapeditor_focus();
	SendNUIMessage({
		type = 'elementProperties',
		action = 'open',
		data = tempTable
	})
end

RegisterNUICallback('onElementProprtiesChange', function(data, cb)
	edfElements[elementProprties.elementData.edfData.type].properties[data.name].applier(elementProprties.elementData.element, data.value);
	
	cb({});
end)

RegisterNUICallback('onElementPropertiesCancel', function(data, cb)
	restoreElementProperties();
	
	elementProprties.enabled = false;
	elementProprties.elementData = nil;
	cb({});
end)

RegisterNUICallback('onElementPropertiesApply', function(data, cb)
	-- no need to apply
	
	elementProprties.enabled = false;
	elementProprties.elementData = nil;
	cb({});
end)