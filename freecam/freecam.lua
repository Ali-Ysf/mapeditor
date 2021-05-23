-- configurable parameters
local options_default = {
	fov						= 50.0,
	slowSpeed				= 0.5,
	regularSpeed 			= 3.0,
	fastSpeed 				= 15.0,
	lookSensitivity			= 8.0
};

local options = {};

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
options = deepcopy(options_default);

-- state variables
local freecamEnabled = false;
local speed = options.regularSpeed;
local camera;
local playerPed;
local offsetRotX = 0.0
local offsetRotY = 0.0
local offsetRotZ = 0.0

-- PRIVATE

--local native_SetFocusArea 					= SetFocusArea;
local native_SetCamCoord  					= SetCamCoord;
local native_SetCamRot						= SetCamRot;
local native_SetEntityCoordsNoOffset 		= SetEntityCoordsNoOffset;
local native_IsDisabledControlPressed 		= IsDisabledControlPressed;
local native_GetDisabledControlNormal		= GetDisabledControlNormal;
local native_SetEntityHeading				= SetEntityHeading;
local abs									= math.abs
local function freecamFrame()
    DisableFirstPersonCamThisFrame();
	
	offsetRotX = offsetRotX - (native_GetDisabledControlNormal(1, 2) * options.lookSensitivity)
	offsetRotZ = offsetRotZ - (native_GetDisabledControlNormal(1, 1) * options.lookSensitivity)
	if (offsetRotX > 90.0) then offsetRotX = 90.0 elseif (offsetRotX < -90.0) then offsetRotX = -90.0 end
	if (offsetRotY > 90.0) then offsetRotY = 90.0 elseif (offsetRotY < -90.0) then offsetRotY = -90.0 end
	if (offsetRotZ > 360.0) then offsetRotZ = offsetRotZ - 360.0 elseif (offsetRotZ < -360.0) then offsetRotZ = offsetRotZ + 360.0 end
	
	local camCoords = GetCamCoord(camera)
	local x, y, z = camCoords.x, camCoords.y, camCoords.z;
	
	if (native_IsDisabledControlPressed(1, 32)) then -- W
		local multCoordY = 0.0
		local multCoordX = 0.0
		if ((offsetRotZ >= 0.0 and offsetRotZ <= 90.0) or (offsetRotZ <= 0.0 and offsetRotZ >= -90.0)) then
			multCoordX = offsetRotZ / 90
			multCoordY = 1.0 - (abs(offsetRotZ) / 90)
		elseif ((offsetRotZ >= 90.0 and offsetRotZ <= 180.0) or (offsetRotZ <= -90.0 and offsetRotZ >= -180.0)) then
			if (offsetRotZ >= 90.0) then
				multCoordX = 1.0 - (offsetRotZ - 90.0) / 90
			else
				multCoordX = - (1.0 + (offsetRotZ + 90.0) / 90)
			end
			multCoordY = - (abs(offsetRotZ) - 90.0) / 90
		elseif ((offsetRotZ >= 180.0 and offsetRotZ <= 270.0) or (offsetRotZ <= -180.0 and offsetRotZ >= -270.0)) then
			if (offsetRotZ >= 180.0) then
				multCoordX = - ((offsetRotZ - 180.0) / 90)
			else
				multCoordX = - (offsetRotZ + 180.0) / 90
			end
			multCoordY = - 1.0 + (abs(offsetRotZ) - 180.0) / 90
		elseif ((offsetRotZ >= 270.0 and offsetRotZ <= 360.0) or (offsetRotZ <= -270.0 and offsetRotZ >= -360.0)) then
			if (offsetRotZ >= 270.0) then
				multCoordX = - (1.0 - ((offsetRotZ - 270.0) / 90))
			else
				multCoordX = 1.0 + (offsetRotZ + 270.0) / 90
			end
			multCoordY = (math.abs(offsetRotZ) - 270.0) / 90
		end

		x = x - (0.1 * speed * multCoordX)
		y = y + (0.1 * speed * multCoordY)
	end
	if (native_IsDisabledControlPressed(1, 33)) then -- S
		local multCoordY = 0.0
		local multCoordX = 0.0
		if ((offsetRotZ >= 0.0 and offsetRotZ <= 90.0) or (offsetRotZ <= 0.0 and offsetRotZ >= -90.0)) then
			multCoordX = offsetRotZ / 90
			multCoordY = 1.0 - (abs(offsetRotZ) / 90)
		elseif ((offsetRotZ >= 90.0 and offsetRotZ <= 180.0) or (offsetRotZ <= -90.0 and offsetRotZ >= -180.0)) then
			if (offsetRotZ >= 90.0) then
				multCoordX = 1.0 - (offsetRotZ - 90.0) / 90
			else
				multCoordX = - (1.0 + (offsetRotZ + 90.0) / 90)
			end
			multCoordY = - (abs(offsetRotZ) - 90.0) / 90
		elseif ((offsetRotZ >= 180.0 and offsetRotZ <= 270.0) or (offsetRotZ <= -180.0 and offsetRotZ >= -270.0)) then
			if (offsetRotZ >= 180.0) then
				multCoordX = - ((offsetRotZ - 180.0) / 90)
			else
				multCoordX = - (offsetRotZ + 180.0) / 90
			end
			multCoordY = - 1.0 + (abs(offsetRotZ) - 180.0) / 90
		elseif ((offsetRotZ >= 270.0 and offsetRotZ <= 360.0) or (offsetRotZ <= -270.0 and offsetRotZ >= -360.0)) then
			if (offsetRotZ >= 270.0) then
				multCoordX = - (1.0 - ((offsetRotZ - 270.0) / 90))
			else
				multCoordX = 1.0 + (offsetRotZ + 270.0) / 90
			end
			multCoordY = (abs(offsetRotZ) - 270.0) / 90
		end

		x = x + (0.1 * speed * multCoordX)
		y = y - (0.1 * speed * multCoordY)
	end
	if (native_IsDisabledControlPressed(1, 34)) then -- A
		local multCoordY = 0.0
		local multCoordX = 0.0
		if ((offsetRotZ >= 0.0 and offsetRotZ <= 90.0) or (offsetRotZ <= 0.0 and offsetRotZ >= -90.0)) then
			multCoordX = 1.0 - (abs(offsetRotZ) / 90)
			multCoordY = - (offsetRotZ / 90)
		elseif ((offsetRotZ >= 90.0 and offsetRotZ <= 180.0) or (offsetRotZ <= -90.0 and offsetRotZ >= -180.0)) then
			if (offsetRotZ >= 90.0) then
				multCoordX = - (offsetRotZ - 90.0) / 90
				multCoordY = - (1.0 - (abs(offsetRotZ) - 90.0) / 90)
			else
				multCoordX = (offsetRotZ + 90.0) / 90
				multCoordY = 1.0 - ((abs(offsetRotZ) - 90.0) / 90)
			end
		elseif ((offsetRotZ >= 180.0 and offsetRotZ <= 270.0) or (offsetRotZ <= -180.0 and offsetRotZ >= -270.0)) then
			if (offsetRotZ >= 180.0) then
				multCoordX = - (1.0 - ((offsetRotZ - 180.0) / 90))
				multCoordY = (abs(offsetRotZ) - 180.0) / 90
			else
				multCoordX = - (1.0 + (offsetRotZ + 180.0) / 90)
				multCoordY = - (abs(offsetRotZ) - 180.0) / 90
			end
		elseif ((offsetRotZ >= 270.0 and offsetRotZ <= 360.0) or (offsetRotZ <= -270.0 and offsetRotZ >= -360.0)) then
			if (offsetRotZ >= 270.0) then
				multCoordX = (offsetRotZ - 270.0) / 90
				multCoordY = 1.0 - (abs(offsetRotZ) - 270.0) / 90
			else
				multCoordX = - (offsetRotZ + 270.0) / 90
				multCoordY = - (1.0 - ((abs(offsetRotZ) - 270.0) / 90))
			end
		end

		x = x - (0.1 * speed * multCoordX)
		y = y + (0.1 * speed * multCoordY)
	end
	if (native_IsDisabledControlPressed(1, 35)) then -- D
		local multCoordY = 0.0
		local multCoordX = 0.0
		if ((offsetRotZ >= 0.0 and offsetRotZ <= 90.0) or (offsetRotZ <= 0.0 and offsetRotZ >= -90.0)) then
			multCoordX = 1.0 - (abs(offsetRotZ) / 90)
			multCoordY = - (offsetRotZ / 90)
		elseif ((offsetRotZ >= 90.0 and offsetRotZ <= 180.0) or (offsetRotZ <= -90.0 and offsetRotZ >= -180.0)) then
			if (offsetRotZ >= 90.0) then
				multCoordX = - (offsetRotZ - 90.0) / 90
				multCoordY = - (1.0 - (abs(offsetRotZ) - 90.0) / 90)
			else
				multCoordX = (offsetRotZ + 90.0) / 90
				multCoordY = 1.0 - ((abs(offsetRotZ) - 90.0) / 90)
			end
		elseif ((offsetRotZ >= 180.0 and offsetRotZ <= 270.0) or (offsetRotZ <= -180.0 and offsetRotZ >= -270.0)) then
			if (offsetRotZ >= 180.0) then
				multCoordX = - (1.0 - ((offsetRotZ - 180.0) / 90))
				multCoordY = (abs(offsetRotZ) - 180.0) / 90
			else
				multCoordX = - (1.0 + (offsetRotZ + 180.0) / 90)
				multCoordY = - (abs(offsetRotZ) - 180.0) / 90
			end
		elseif ((offsetRotZ >= 270.0 and offsetRotZ <= 360.0) or (offsetRotZ <= -270.0 and offsetRotZ >= -360.0)) then
			if (offsetRotZ >= 270.0) then
				multCoordX = (offsetRotZ - 270.0) / 90
				multCoordY = 1.0 - (abs(offsetRotZ) - 270.0) / 90
			else
				multCoordX = - (offsetRotZ + 270.0) / 90
				multCoordY = - (1.0 - ((abs(offsetRotZ) - 270.0) / 90))
			end
		end

		x = x + (0.1 * speed * multCoordX)
		y = y - (0.1 * speed * multCoordY)
	end
	if (native_IsDisabledControlPressed(1, 46)) then -- E
		z = z + (0.1 * speed)
	end
	if (native_IsDisabledControlPressed(1, 26)) then -- C
		z = z - (0.1 * speed)
	end
	if (native_IsDisabledControlPressed(1, 21)) then -- LEFT SHIFT
		speed = options.fastSpeed;
	else
		if (native_IsDisabledControlPressed(1, 19)) then -- LEFT ALT
			speed = options.slowSpeed;
		else
			if (speed ~= options.regularSpeed) then
				speed = options.regularSpeed;
			end
		end
	end
	
	--native_SetFocusArea(x, y, z, 0.0, 0.0, 0.0);
	native_SetCamCoord(camera, x, y, z);
	native_SetCamRot(camera, offsetRotX, offsetRotY, offsetRotZ, 2);
	--SetEntityVelocity(playerPed, 0.0, 0.0, 0.0);
	native_SetEntityCoordsNoOffset(playerPed, x, y, z, true, true, true);
	native_SetEntityHeading(playerPed, offsetRotZ);
end
-- PUBLIC

function getFreecamVelocity()
	return velocityX,velocityY,velocityZ
end

-- params: x, y, z  sets camera's position (optional)
function setFreecamEnabled (x, y, z)
	if isFreecamEnabled() then
		return false
	end
	
	ClearFocus();
	
	playerPed = GetPlayerPed(-1);
	SetEntityVisible(playerPed, false, 0);
	--[[if (x and y and z) then
		native_SetEntityCoordsNoOffset(playerPed, x, y, z, true, true, true);
	end
	camera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", x or 0, y or 0, z or 0, 0, 0, 0, options.fov * 1.0);]]
	camera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", GetEntityCoords(playerPed), 0, 0, 0, options.fov * 1.0);
	SetCamActive(camera, true);
	RenderScriptCams(true, false, 0, true, false);
	SetCamAffectsAiming(camera, false);
	SetEntityCollision(playerPed, false, true);

	--[[if (x and y and z) then
	    native_SetCamCoord(camera, x, y, z);
		native_SetEntityCoordsNoOffset(playerPed, x, y, z, true, true, true);
	end]]
	freecamEnabled = true;
	
	Citizen.CreateThread(function()
		while freecamEnabled do
			Citizen.Wait(1);
			freecamFrame();
		end
	end);

	return camera;
end

-- param:  dontChangeFixedMode  leaves toggleCameraFixedMode alone if true, disables it if false or nil (optional)
function setFreecamDisabled()
	if not isFreecamEnabled() then
		return false
	end
	
	freecamEnabled = false;
	
	--ClearFocus()
	SetEntityVisible(playerPed, true, 0);
    RenderScriptCams(false, false, 0, true, false);
    DestroyCam(camera, false);
	--SetFocusEntity(playerPed);
	SetEntityCollision(playerPed, true, true);
	playerPed = nil;

	return true
end

function setFreecamPosition(x, y, z)
	if not isFreecamEnabled() then
		return false
	end
	
	native_SetCamCoord(camera, x, y, z);
	native_SetEntityCoordsNoOffset(playerPed, x, y, z, true, true, true);
	
	return true
end

function setFreecamRotation(rx, ry, rz)
	if not isFreecamEnabled() then
		return false
	end
	
	native_SetCamRot(camera, rx, ry, rz, 2);
	offsetRotX, offsetRotY, offsetRotZ = rx, ry, rz;
	
	return true
end

function getFreecamPosition()
	if not isFreecamEnabled() then
		return false
	end
	
	local coords = GetCamCoord(camera);
	
	return coords;
end

function getFreecamRotation()
	if not isFreecamEnabled() then
		return false
	end
	
	local coords = GetCamRot(camera, 2);
	
	return coords;
end

function getFreecamMatrix()
	if not isFreecamEnabled() then
		return false
	end
	
	local rightVector, forwardVector, upVector, position = GetCamMatrix(camera);
	print(rightVector, forwardVector);
	
	return rightVector, forwardVector, upVector, position;
end

function getFreecamCam()
	if not isFreecamEnabled() then
		return false
	end
	
	return camera;
end

function isFreecamEnabled()
	return freecamEnabled;
end

function getFreecamOption(theOption)
	return options[theOption]
end

function setFreecamOption(theOption, value)
	if options[theOption] ~= nil then
		options[theOption] = value
		return true
	else
		return false
	end
end

function resetFreecamOption()
	options = deepcopy(options_default);
end

RegisterCommand("freecam", function(source, args, rawCommand)
	--print(source);
    --if source > 0 then
		--print('test');
        if ( isFreecamEnabled() ) then
			setFreecamDisabled();
		else
			setFreecamEnabled();
			print('enabled');
		end
    --end
end)

AddEventHandler("onResourceStop",
function(resource)
	if (resource ~= GetCurrentResourceName()) then
		return false;
	end
	
	setFreecamDisabled();
end);