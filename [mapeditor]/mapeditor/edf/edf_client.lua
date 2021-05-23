local edf = {};

RegisterNetEvent('mapeditor:edf_clientCacheEdf');
AddEventHandler('mapeditor:edf_clientCacheEdf',
function(serverEdf)
	edf = serverEdf;
	updateMapSettings.edf(edf);
end)

local function proccessHash(hash, callback)
	Citizen.CreateThread(function()
		RequestModel(hash);
		local trys = 0;
		while (not HasModelLoaded(hash)) do
			trys = trys+1;
			if (trys >= 500) then
				callback(false);
				break;
			end
			Citizen.Wait(0);
		end
		
		callback(true);
		SetModelAsNoLongerNeeded(hash);
	end)
end

local edfCreateBasic = {
	object = function(data, elementModel, coords, cb)
		local hash = type(elementModel) == 'number' and elementModel or type(elementModel) == 'string' and GetHashKey(elementModel) or GetHashKey(data.model.default or 'prop_mp_cone_02');
		
		return proccessHash(hash, function(success)
			if (success) then
				local object = CreateObjectNoOffset(hash, coords, true, true, false);
				
				if (cb) then
					cb(object or false);
				end
				--return object or false
			end
		end);
	end,
	vehicle = function(data, elementModel, coords, cb)
		local hash = type(elementModel) == 'number' and elementModel or type(elementModel) == 'string' and GetHashKey(elementModel) or GetHashKey(data.model.default or 'Infernus');
		proccessHash(hash, function(success)
			if (success) then
				local vehicle = CreateVehicle(hash, coords, 0, true, true);
				
				SetVehicleGravity(vehicle, false);
				
				if (cb) then
					cb(vehicle or false);
				end
			end
		end);
	end,
	ped = function(data, elementModel, coords, cb)
		local hash = type(elementModel) == 'number' and elementModel or type(elementModel) == 'string' and GetHashKey(elementModel) or GetHashKey(data.model.default or 'Franklin');
		proccessHash(hash, function(success)
			if (success) then
				local ped = CreatePed(data.pedType, hash, coords, 0, true, true);
				
				if (cb) then
					cb(ped or false);
				end
			end
		end);
	end,
	pickup = function(data, cb)
		local hash = GetHashKey(data.model.default or 'prop_mp_cone_02');
		proccessHash(hash, function(success)
			if (success) then
				local pickup = CreatePickup(hash, GetEntityCoords(GetPlayerPed(PlayerId())), 0, true, true);
				
				if (cb) then
					cb(pickup or false);
				end
			end
		end);
	end,
	marker = function(data, cb)
		local mType = GetHashKey(data.type.default or 'prop_mp_cone_02');
		CreateMarker(data);
	end
}

function edfGetDefinitions()
	return edf;
end

function edfCreateElement(elementName, resourceName, elementModel, coords, cb)
	local theEdf = edfGet(resourceName);
	
	if ( not theEdf ) then
		print("invalid resource (doesn't match selected edfs)");
		-- invalid resource (doesn't match selected edfs)
		return false;
	end
	
	local edfElement = edfGetElementData(theEdf, elementName);
	
	if ( not edfElement ) then
		print("invalid element (element does not exists in selected edfs)");
		-- invalid element (element does not exists in selected edfs)
		return false;
	end
	
	if ( not edfCreateBasic[edfElement.type] ) then
		print("invalid basic element type (no custom types support rn)");
		-- invalid basic element type (no custom types support rn)
		return false;
	end
	
	edfCreateBasic[edfElement.type](edfIndexElementData(edfElement), elementModel, coords, cb);
	return true;
end