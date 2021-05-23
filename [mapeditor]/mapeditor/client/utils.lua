function displayToast(text, delay)
	assert(type(text) == 'string', "Bad argument @displayToast at argument 1, expect string got "..type(text));
	if (delay) then
		assert(type(delay) == 'number', "Bad argument @displayToast at argument 2, expect number got "..type(delay));
	else
		delay = 5000;
	end
	
	SendNUIMessage({
		type = 'displayToast',
		message = text,
		delay = delay
	})
end

function getMaps()
	local maps = {};
	local resNum = GetNumResources();
	for i=0, resNum-1 do
		local resName = GetResourceByFindIndex(i)
		if (resName) then
			if (GetNumResourceMetadata(resName, 'resource_type') > 0) then
				
				if (GetResourceMetadata(resName, 'resource_type', 0) == 'map') then
					table.insert(maps, resName);
				end
			end
		end
	end
	return maps;
end

function toBool(str)
	return str == 'true';
end

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

--[[local rad = math.rad;
local abs = math.abs;
local cos = math.cos;
local sin = math.sin;
function getWorldCoordFromMousePosition()

end

local function RotationToDirection(rotation)
	local z = rad(rotation[1]);
	local x = rad(rotation[3]);
	local num = abs(cos(x));
	return vector3(-sin(z) * num, cos(z) * num, sin(x));
end

function ScreenRelToWorld(camPos, camRot, coord)
	local camForward 	= RotationToDirection(camRot);
	local rotUp 		= camRot + vector3(1, 0, 0);
	local rotDown 		= camRot + vector3(-1, 0, 0);
	local rotLeft 		= camRot + vector3(0, 0, -1);
	local rotRight 		= camRot + vector3(0, 0, 1);
	
	local camRight 	= RotationToDirection(rotRight) - RotationToDirection(rotLeft);
	local camUp 	= RotationToDirection(rotUp) - RotationToDirection(rotDown);
	
	local rollRad = -rad(camRot[2]);
	
	local camRightRoll 	= camRight * cos(rollRad) - camUp * sin(rollRad);
	local camUpRoll		= camRight * sin(rollRad) + camUp * cos(rollRad);
	
	local point3D = camPos + camForward * 1.0 + camRightRoll + camUpRoll;
	local ali, point2Dx, point2Dy = GetScreenCoordFromWorldCoord(point3D[1], point3D[2], point3D[3]);
	if (not ali) then
		local forwardDirection = camForward;
		print('1st return');
		return camPos + camForward * 1.0, forwardDirection;
	end
	
	local point3DZero = camPos + camForward * 1.0;
	local yousif, point2DZerox, point2DZeroy = GetScreenCoordFromWorldCoord(point3DZero[1], point3DZero[2], point3DZero[3]);
	if (not yousif) then
		local forwardDirection = camForward;
		print('2nd return');
		return camPos + camForward * 1.0, forwardDirection;
	end
	
	print('point2D', point2Dx, point2Dy);
	print('point2DZero', point2DZerox, point2DZeroy);
	
	local eps = 0.001;
	if (abs(point2Dx - point2DZerox) < eps or abs(point2Dy - point2DZeroy) < eps) then
		local forwardDirection = camForward;
		print('3rd return');
		return camPos + camForward * 1.0, forwardDirection;
	end
	local scaleX = (coord[1] - point2DZerox) / (point2Dx - point2DZerox);
	local scaleY = (coord[2] - point2DZeroy) / (point2Dy - point2DZeroy);
	--print('scaleX', (coord[1] - point2DZerox), (point2Dx - point2DZerox));
	local point3Dret = camPos + camForward * 1.0 + camRightRoll * scaleX + camUpRoll + scaleY;
	local forwardDirection = camForward + camRightRoll * scaleX + camUpRoll * scaleY;
	print('4th return');
	return point3Dret, forwardDirection;
end]]