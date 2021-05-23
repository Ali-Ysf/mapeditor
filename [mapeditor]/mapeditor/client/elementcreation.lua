local elements = {};

local editorDecor = DecorRegister('editor_element', 2);

function isEditorEntity(element)
	if (element) then
		if (NetworkGetEntityIsNetworked(element)) then
			local netID = NetworkGetNetworkIdFromEntity(element);
			if (netID and elements[netID]) then
				return true;
			end
		end
	end
	return false;
end

function getEditorEntity(element)
	if (element) then
		if (NetworkGetEntityIsNetworked(element)) then
			local netID = NetworkGetNetworkIdFromEntity(element);
			if (netID and elements[netID]) then
				return elements[netID];
			end
		end
	end
	return false
end

function doCreateElement(elementName, resourceName, attach, elementModel, pos)
	local _, forwardVector, _, position = GetCamMatrix(exports.freecam:getFreecamCam());
	local pos = (forwardVector * 10) + position;
	if (
		not edfCreateElement(elementName, resourceName, elementModel, pos,
			function(element)
				if (element and DoesEntityExist(element)) then
					print('(client)element created');
					TriggerServerEvent( "doCreateElement", NetworkGetNetworkIdFromEntity(element), elementName, resourceName, attach );
				end
			end)
	) then
		-- element creation failed
		print('doCreateElement failed');
		return false;
	end
end

RegisterNetEvent('onClientElementCreate');
AddEventHandler('onClientElementCreate',
function(elementNetID, elementName, resourceName, creator, attach)
	elements[elementNetID] = {edf=resourceName, elementType=elementName};
	
	if (creator == GetPlayerServerId(PlayerId())) then
		holdElement(NetworkGetEntityFromNetworkId(elementNetID));
	end
end)

RegisterNetEvent('doClientLoadMap');
AddEventHandler('doClientLoadMap',
function(elmnts)
	for k,v in pairs(elmnts) do
		elements[v.netID] = v;
	end
end)