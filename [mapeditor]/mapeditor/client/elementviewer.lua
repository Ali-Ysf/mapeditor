local viewElement = {
	enabled					= false,
	element					= nil,
	elementRotation 		= 0,
	spawnInProcess			= false,
	cb						= nil
}

local function rotateElement()
	if (viewElement.element) then
		viewElement.elementRotation = viewElement.elementRotation < 360 and viewElement.elementRotation+1 or 0;
		SetEntityHeading(viewElement.element, viewElement.elementRotation);
		--print(viewElement.elementRotation);
	end
end

local function createTmpObject(objName)
	Citizen.CreateThread(function()
		if (viewElement.element and IsAnEntity(viewElement.element)) then
			DeleteObject(viewElement.element);
			viewElement.element = nil;
		end

		viewElement.spawnInProcess = true;
		local objHash = GetHashKey(objName);
		RequestModel(objHash);
		local trys = 0;
		while (not HasModelLoaded(objHash)) do
			trys = trys+1;
			if (trys >= 50) then
				displayToast('Failed loading '..objName);
				break;
			end
			Citizen.Wait(5);
		end
		
		viewElement.element = CreateObjectNoOffset(objHash, GetEntityCoords(GetPlayerPed(PlayerId())), false, true, false); -- 4784.677, 6331.745, 1347.34
		NetworkRequestControlOfEntity(viewElement.element);
		SetModelAsNoLongerNeeded(objHash);
		viewElement.spawnInProcess = false;
	end);
end

Citizen.CreateThread(
function()
	while true do
		Wait(1);
		
		if (viewElement.element) then
			local _, forwardVector, _, position = GetCamMatrix(MAPEDITOR.camera);
			local newObjectPosition = position + (forwardVector * 7);
			
			SetEntityCoords(viewElement.element, newObjectPosition);
		end
	end
end
);

function initElementViewer(elementType, defaultModel, cb)
	viewElement.enabled = true;
	viewElement.cb = cb;
	
	SendNUIMessage({
		type = 'elementViewer',
		action = 'open',
		elementType = elementType
	})
	
	viewElement.lastCoords = exports.freecam:getFreecamPosition();
	viewElement.lastRotation = exports.freecam:getFreecamRotation();
	
	--exports.freecam:setFreecamPosition(4784.677, 6321.745, 1347.34);
	--exports.freecam:setFreecamRotation(0, 0, 0);
	
	Citizen.CreateThread(function()
		while viewElement.enabled do
			Wait(50);
			rotateElement();
		end
	end)
	
	createTmpObject(defaultModel);
end

function destroyElementViewer(data, cb)
	viewElement.enabled = false;
	--exports.freecam:setFreecamPosition(viewElement.lastCoords[1], viewElement.lastCoords[2], viewElement.lastCoords[3]);
	--exports.freecam:setFreecamRotation(viewElement.lastRotation[1], viewElement.lastRotation[2], viewElement.lastRotation[3]);
	
	viewElement.lastCoords = nil;
	viewElement.lastRotation = nil;
	
	local elementModel = false;
	if (data and data[1] and data[1] == true) then
		elementModel = GetEntityModel(viewElement.element);
		--mapeditor_unfocus({});
	end
	
	if (viewElement.element and IsAnEntity(viewElement.element)) then
		DeleteObject(viewElement.element);
		viewElement.element = nil;
	end
	
	viewElement.cb( elementModel );
	
	if cb then cb({}); end
end
RegisterNUICallback('destroyViewer', destroyElementViewer);

RegisterNUICallback('onModelSelect', function(data, cb)
	if (not viewElement.spawnInProcess) then
		createTmpObject(data[1]);
	end
	cb({});
end)

function viewElement_onResourceStop()
	if (viewElement.enabled) then
		destroyElementViewer({});
	end
end