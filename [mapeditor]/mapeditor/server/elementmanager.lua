MAPEDITOR.elements = {};

function eraseEditorElements()
	for k,v in pairs(MAPEDITOR.elements) do
		if (DoesEntityExist(k)) then
			DeleteEntity(k);
		end
	end
	
	MAPEDITOR.elements = {};
	TriggerClientEvent("doClientLoadMap", -1, MAPEDITOR.elements);
end

function setupNewElement(element, elementName, resourceName, creator, attach)
	local elementNetID = NetworkGetNetworkIdFromEntity(element);
	
	MAPEDITOR.elements[element] = {edf=resourceName, elementType=elementName, netID=elementNetID, modelName = HashToName(GetEntityModel(element))};
	
	TriggerEvent("onElementCreate", element);
	TriggerClientEvent("onClientElementCreate", -1, elementNetID, elementName, resourceName, creator, attach);
end

RegisterNetEvent('doCreateElement');
AddEventHandler('doCreateElement',
function(elementNetID, elementName, resourceName, attach)
	local creator = source;
	
	Citizen.CreateThread(
	function()
		local counter = 0
		repeat
			counter = counter+1;
			local element = NetworkGetEntityFromNetworkId(elementNetID);
		
			if (element and DoesEntityExist(element)) then
				setupNewElement(element, elementName, resourceName, creator, attach);
				print('(server)element setup successfully');
				break;
			else
				Wait(20);
			end
		until counter >= 50
		
		if (counter >= 50) then
			print('(server)element setup failed. element can not be found');
		end
	end
	)
end)

AddEventHandler('onResourceStop',
function(resource)
	if (GetCurrentResourceName() ~= resource) then
		return false;
	end
	
	for k,v in pairs(MAPEDITOR.elements) do
		if (DoesEntityExist(k)) then
			DeleteEntity(k);
		end
	end
end)

RegisterNetEvent('onMapEditorPlayerReady');
AddEventHandler('onMapEditorPlayerReady',
function()
	TriggerClientEvent("doClientLoadMap", source, MAPEDITOR.elements);
end)