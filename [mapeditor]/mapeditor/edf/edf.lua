local edf = {
	default			= nil,
	selected		= nil,
	available 		= {}
}

function edfLoadDefinition(resource)
	local edfFileName = GetResourceMetadata(resource, 'edf', 0);
	if (edfFileName) then
		local edfFileContent = LoadResourceFile(resource, edfFileName);
		if (edfFileContent) then
			local resourceEdf = json.decode(edfFileContent);
			resourceEdf.resource = resource;
			if (resourceEdf) then
				return resourceEdf;
			end
		end
	end
	return false;
end

function edfLoadAllDefinitions()
	edf.available = {}
	local numRes = GetNumResources();
	for i=0, numRes-1 do
		local res = GetResourceByFindIndex(i);
		if (res and res ~= 'mapeditor') then
			local resEdf = edfLoadDefinition(res);
			if (resEdf) then
				table.insert(edf.available, resEdf);
			end
		end
	end
end

function edfGetDefinitions()
	return edf;
end

AddEventHandler("onResourceStart",
function(resource)
	if (GetCurrentResourceName() ~= resource) then
		return false;
	end
	
	edf.default = edfLoadDefinition('mapeditor');
	
	edfLoadAllDefinitions();
end)

RegisterNetEvent('onMapEditorPlayerReady');
AddEventHandler('onMapEditorPlayerReady',
function()
	TriggerClientEvent('mapeditor:edf_clientCacheEdf', source, edf);
end)