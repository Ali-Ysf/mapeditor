sx, sy = GetActiveScreenResolution();
g_heldElement = nil;
g_selectedElement = nil;
g_targettedElement = nil;
local objectForwardDistance = 10;
local dbLastClick = 0;

local entityTypes = {
	[0] = "no-entity",
	[1] = "ped",
	[2] = "vehicle",
	[3] = "object"
}

local crosshair 	= {};
crosshair.enabled	= false;
crosshair.txd 		= CreateRuntimeTxd('crosshairtxd');
crosshair.tx  		= CreateRuntimeTextureFromImage(crosshair.txd, 'crosshair', 'crosshair.png');
crosshair.width 	= 32/sx;
crosshair.height 	= 32/sy;
crosshair.r, crosshair.g, crosshair.b = 255, 255, 255;
crosshair.alpha 	= 170;

local function drawCrosshair()
	DrawSprite('crosshairtxd', 'crosshair', 0.5, 0.5, crosshair.width, crosshair.height, 0.0, crosshair.r, crosshair.g, crosshair.b, crosshair.alpha);
end

-- based on MFAINS code from MenyooSP
-- https://github.com/MAFINS/MenyooSP/blob/master/Solution/source/Submenus/Spooner/EntityManagement.cpp
local function drawModelBoundingBox(data)
	if (data) then
		local boxUpperLeftRear = GetOffsetFromEntityInWorldCoords(data.element, -data.dim2.x, -data.dim2.y, data.dim2.z);
		local boxUpperRightRear = GetOffsetFromEntityInWorldCoords(data.element, -data.dim1.x, -data.dim2.y, data.dim2.z);
		local boxLowerLeftRear = GetOffsetFromEntityInWorldCoords(data.element, -data.dim2.x, -data.dim2.y, data.dim1.z);
		local boxLowerRightRear = GetOffsetFromEntityInWorldCoords(data.element, -data.dim1.x, -data.dim2.y, data.dim1.z);
		
		local boxUpperLeftFront = GetOffsetFromEntityInWorldCoords(data.element, -data.dim2.x, -data.dim1.y, data.dim2.z);
		local boxUpperRightFront = GetOffsetFromEntityInWorldCoords(data.element, -data.dim1.x, -data.dim1.y, data.dim2.z);
		local boxLowerLeftFront = GetOffsetFromEntityInWorldCoords(data.element, -data.dim2.x, -data.dim1.y, data.dim1.z);
		local boxLowerRightFront = GetOffsetFromEntityInWorldCoords(data.element, -data.dim1.x, -data.dim1.y, data.dim1.z);
		
		DrawLine(boxUpperLeftRear, boxUpperRightRear, 255, 0, 0, 170);
		--DrawMarker(28, boxUpperLeftRear, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 0, 50, false, true, 2, nil, nil, false);
		--DrawMarker(28, boxUpperRightRear, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 50, false, true, 2, nil, nil, false);
		DrawLine(boxLowerLeftRear, boxLowerRightRear, 255, 0, 0, 170);
		DrawLine(boxUpperLeftRear, boxLowerLeftRear, 255, 0, 0, 170);
		DrawLine(boxUpperRightRear, boxLowerRightRear, 255, 0, 0, 170);
		
		DrawLine(boxUpperLeftFront, boxUpperRightFront, 255, 0, 0, 170);
		DrawLine(boxLowerLeftFront, boxLowerRightFront, 255, 0, 0, 170);
		DrawLine(boxUpperLeftFront, boxLowerLeftFront, 255, 0, 0, 170);
		DrawLine(boxUpperRightFront, boxLowerRightFront, 255, 0, 0, 170);
		
		DrawLine(boxUpperLeftRear, boxUpperLeftFront, 255, 0, 0, 170);
		DrawLine(boxUpperRightRear, boxUpperRightFront, 255, 0, 0, 170);
		DrawLine(boxLowerLeftRear, boxLowerLeftFront, 255, 0, 0, 170);
		DrawLine(boxLowerRightRear, boxLowerRightFront, 255, 0, 0, 170);
		
		--[[DrawPoly(boxUpperRightRear, boxLowerRightRear, boxUpperLeftRear, 255, 255, 255, 170);
		DrawPoly(boxUpperLeftRear, boxLowerLeftRear, boxLowerRightRear, 255, 255, 255, 170);

		DrawPoly(boxUpperRightFront, boxLowerRightFront, boxUpperLeftFront, 255, 255, 255, 170);
		DrawPoly(boxUpperLeftFront, boxLowerLeftFront, boxLowerRightFront, 255, 255, 255, 170);

		DrawPoly(boxUpperLeftFront, boxLowerLeftFront, boxUpperLeftRear, 255, 255, 255, 170);
		DrawPoly(boxUpperLeftRear, boxLowerLeftFront, boxLowerLeftRear, 255, 255, 255, 170);

		DrawPoly(boxUpperRightFront, boxLowerRightFront, boxUpperRightRear, 255, 255, 255, 170);
		DrawPoly(boxUpperRightRear, boxLowerRightFront, boxLowerRightRear, 255, 255, 255, 170);

		DrawPoly(boxUpperRightFront, boxUpperRightRear, boxUpperLeftRear, 255, 255, 255, 170);
		DrawPoly(boxUpperLeftFront, boxUpperRightFront, boxUpperLeftRear, 255, 255, 255, 170);

		DrawPoly(boxLowerRightFront, boxLowerRightRear, boxLowerLeftRear, 255, 255, 255, 170);
		DrawPoly(boxLowerLeftFront, boxLowerRightFront, boxLowerLeftRear, 255, 255, 255, 170);]]
	end
end

local function drawMarkerAboveElement(data, ex, ey, ez)
	DrawMarker(0, ex, ey, ez+data.markerHeight, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 255, 0, 50, false, true, 2, nil, nil, false);
end

local function roundRotation ( rot )
	if rot < 45 then
		return -rot
	else
		return (90 - rot) end
end
local ali = true;
local native_IsDisabledControlPressed = IsDisabledControlPressed;
local function proccessCrosshair()
	HideHudComponentThisFrame(19);
	drawCrosshair()
	
	local _, forwardVector, _, position = GetCamMatrix(MAPEDITOR.camera);
	
	if (g_selectedElement) then
		if (not DoesEntityExist(g_selectedElement.element)) then
			deselectElement();
		end
		local moveThisFrame = false;
		local selectedCoords = GetEntityCoords(g_selectedElement.element);
		local selectedCoordsX, selectedCoordsY, selectedCoordsZ = selectedCoords.x, selectedCoords.y, selectedCoords.z
		if (MAPEDITOR_SETTINGS.boundingbox_select) then
			drawModelBoundingBox(g_selectedElement);
		end
		drawMarkerAboveElement(g_selectedElement, selectedCoordsX, selectedCoordsY, selectedCoordsZ);
		
		local upArrow = native_IsDisabledControlPressed(1, 27);
		local downArrow = native_IsDisabledControlPressed(1, 173);
		local leftArrow = native_IsDisabledControlPressed(1, 174);
		local rightArrow = native_IsDisabledControlPressed(1, 175);
		local pageUp = native_IsDisabledControlPressed(1, 10);
		local pageDown = native_IsDisabledControlPressed(1, 11);
		local leftCtrl = native_IsDisabledControlPressed(1, 36);
		
		if (upArrow or downArrow or leftArrow or rightArrow or pageUp or pageDown) then
			if (leftCtrl) then -- control rotation
				local speed = MAPEDITOR_SETTINGS.entity_rotation_normal;
				if (native_IsDisabledControlPressed(1, 19)) then
					speed = MAPEDITOR_SETTINGS.entity_rotation_slow;
				elseif (native_IsDisabledControlPressed(1, 21)) then
					speed = MAPEDITOR_SETTINGS.entity_rotation_fast;
				end
			
				local selectedRoot = GetEntityRotation(g_selectedElement.element, 2);
				local selectedRootX, selectedRootY, selectedRootZ = selectedRoot.x, selectedRoot.y, selectedRoot.z;
				
				if (upArrow) then -- up arrow
					selectedRootX = selectedRootX + speed;
				end
				if (downArrow) then -- down arrow
					selectedRootX = selectedRootX - speed;
				end
				if (leftArrow) then -- left arrow
					selectedRootZ = selectedRootZ - speed;
				end
				if (rightArrow) then -- right arrow
					selectedRootZ = selectedRootZ + speed;
				end
				
				if (pageUp) then
					selectedRootY = selectedRootY + speed;
				end
				if (pageDown) then
					selectedRootY = selectedRootY - speed;
				end
				
				SetEntityRotation(g_selectedElement.element, vector3(selectedRootX, selectedRootY, selectedRootZ), 2);
			else -- control position
				local speed = MAPEDITOR_SETTINGS.entity_movement_normal;
				if (native_IsDisabledControlPressed(1, 19)) then
					speed = MAPEDITOR_SETTINGS.entity_movement_slow;
				elseif (native_IsDisabledControlPressed(1, 21)) then
					speed = MAPEDITOR_SETTINGS.entity_movement_fast;
				end
			
				local camRot = GetCamRot(MAPEDITOR.camera, 2);
				local camRotX, camRotY, camRotZ = camRot.x, 180, (-camRot.z)%360;
				if (MAPEDITOR_SETTINGS.entity_movement_lock_axes) then
					local remainder = math.fmod ( camRotZ, 90 );
					camRotZ = camRotZ + roundRotation ( remainder );
				end
				
				camRotZ = math.rad(camRotZ)
				local distanceX = speed * math.cos(camRotZ);
				local distanceY = speed * math.sin(camRotZ);
				
				if (upArrow) then -- up arrow
					selectedCoordsX = selectedCoordsX + distanceY;
					selectedCoordsY = selectedCoordsY + distanceX;
				end
				if (downArrow) then -- down arrow
					selectedCoordsX = selectedCoordsX - distanceY;
					selectedCoordsY = selectedCoordsY - distanceX;
				end
				if (leftArrow) then -- left arrow
					selectedCoordsX = selectedCoordsX - distanceX;
					selectedCoordsY = selectedCoordsY + distanceY;
				end
				if (rightArrow) then -- right arrow
					selectedCoordsX = selectedCoordsX + distanceX;
					selectedCoordsY = selectedCoordsY - distanceY;
				end
				
				if (pageUp) then
					selectedCoordsZ = selectedCoordsZ + speed;
				end
				if (pageDown) then
					selectedCoordsZ = selectedCoordsZ - speed;
				end
				
				SetEntityCoords(g_selectedElement.element, vector3(selectedCoordsX, selectedCoordsY, selectedCoordsZ));
			end
		end
	end
	
	if (g_heldElement) then
		if (not DoesEntityExist(g_heldElement.element)) then
			unholdElement();
		end
		if (IsDisabledControlJustPressed(1, 241)) then
			objectForwardDistance = math.min(objectForwardDistance+1, g_heldElement.offset+40);
		elseif (IsDisabledControlJustPressed(1, 242)) then
			objectForwardDistance = math.max(objectForwardDistance-1, g_heldElement.offset);
		end
	
		local pos = (forwardVector * objectForwardDistance) + position;
		
		local ray = StartShapeTestRay(position.x, position.y, position.z, pos.x, pos.y, pos.z, -1, g_heldElement.element, 7);
		local _, hit, endCoords = GetShapeTestResult(ray);
		--print('hit', hit);
		if (hit == 1) then
			SetEntityCoordsNoOffset(g_heldElement.element, endCoords.x, endCoords.y, endCoords.z);
			
			if (MAPEDITOR_SETTINGS.boundingbox_hold) then
				drawModelBoundingBox(g_heldElement);
			end
			drawMarkerAboveElement(g_heldElement, endCoords.x, endCoords.y, endCoords.z);
		else
			SetEntityCoords(g_heldElement.element, pos.x, pos.y, pos.z);
			
			if (MAPEDITOR_SETTINGS.boundingbox_hold) then
				drawModelBoundingBox(g_heldElement);
			end
			drawMarkerAboveElement(g_heldElement, pos.x, pos.y, pos.z);
		end
		
		if (IsDisabledControlJustPressed(1, 330)) then
			unholdElement();
		end
	else
		local pos = (forwardVector * 40) + position;
		
		local ray = StartShapeTestRay(position.x, position.y, position.z, pos.x, pos.y, pos.z, -1, 0, 7);
		local _, hit, endCoords, _, entityHit = GetShapeTestResult(ray);
		if (hit == 1) then
			if (isEditorEntity(entityHit)) then
				if (g_targettedElement ~= entityHit) then
					g_targettedElement = entityHit;
					crosshair.alpha = 222;
					crosshair.r, crosshair.g, crosshair.b = 0, 191, 255;
				end
			else
				if (g_targettedElement) then
					g_targettedElement = nil;
					crosshair.alpha = 170;
					crosshair.r, crosshair.g, crosshair.b = 255, 255, 255;
				end
			end
		else
			if (g_targettedElement) then
				g_targettedElement = nil;
				crosshair.alpha = 170;
				crosshair.r, crosshair.g, crosshair.b = 255, 255, 255;
			end
		end
	end
	
	if (g_targettedElement) then
		SetTextFont(0);
		SetTextProportional(1);
		SetTextScale(0.0, 0.2);
		SetTextColour(128, 128, 128, 255);
		SetTextDropshadow(0, 0, 0, 0, 255);
		SetTextEdge(1, 0, 0, 0, 255);
		SetTextDropShadow();
		SetTextOutline();
		SetTextCentre(true);
		SetTextEntry("STRING")
		AddTextComponentString("[".. entityTypes[GetEntityType(g_targettedElement)] .."]\n"..( string.format("%.3f", #(position - GetEntityCoords(g_targettedElement))) ).."m");
		DrawText(0.5, 0.5-(crosshair.height*2));
	
		if (IsDisabledControlJustPressed(1, 329)) then
			selectElement(g_targettedElement);
			
			if (GetGameTimer()-dbLastClick < 250) then
				onElementDoubleClick(g_targettedElement);
			end
			dbLastClick = GetGameTimer();
		elseif (IsDisabledControlJustPressed(1, 330)) then
			holdElement(g_targettedElement);
			g_targettedElement = nil;
		end
	else
		if (g_selectedElement) then
			if (IsDisabledControlJustPressed(1, 329) or IsDisabledControlJustPressed(1, 330)) then
				deselectElement();
			end
		end
	end
end

function toggleCrosshair(bool)
	if (bool) then
		if (crosshair.enabled) then return false end;
		
		crosshair.enabled = true;
		Citizen.CreateThread(
		function()
			while crosshair.enabled do
				Wait(0);
				proccessCrosshair();
				
			end
		end)
	else
		if (not crosshair.enabled) then return false end;
		
		crosshair.enabled = false;
		unholdElement();
	end
end
toggleCrosshair(true);

-------------------------------------
--			HOLD ELEMENT
-------------------------------------
function holdElement(element)
	if (not g_heldElement) then
		if (elementProprties.enabled) then
			return false;
		end
		if (g_selectedElement) then
			deselectElement()
		end

		NetworkRequestControlOfEntity(element);
		
		g_heldElement = {};
		g_heldElement.element = element;
		g_heldElement.dim1, g_heldElement.dim2 = GetModelDimensions(GetEntityModel(g_heldElement.element));
		g_heldElement.markerHeight = math.max(g_heldElement.dim1.z, g_heldElement.dim2.z) + 1.4;
		g_heldElement.offset = math.max(g_heldElement.dim2.x-g_heldElement.dim1.x, g_heldElement.dim2.y-g_heldElement.dim1.y) + 1.4;
		objectForwardDistance = math.min(objectForwardDistance+1, g_heldElement.offset+40);
		objectForwardDistance = math.max(objectForwardDistance-1, g_heldElement.offset);
		
		SetEntityCollision(g_heldElement.element, false, true);
		
		g_heldElement.blip = AddBlipForEntity(g_heldElement.element);
		SetBlipSprite(g_heldElement.blip, 615);
		SetBlipDisplay(g_heldElement.blip, 8);
		SetBlipScale(g_heldElement.blip, 0.9);
		SetBlipColour(g_heldElement.blip, 5);
		--SetBlipAsShortRange(info.blip, true);
		BeginTextCommandSetBlipName("STRING");
		AddTextComponentString("Selected Object");
		EndTextCommandSetBlipName(g_heldElement.blip);
		
		PlaySoundFrontend(-1, 'Select_Placed_Prop', 'DLC_Dmod_Prop_Editor_Sounds', 1); ali = false;
	end
end

function unholdElement()
	if (g_heldElement) then
		SetEntityCollision(g_heldElement.element, true, true);
		RemoveBlip(g_heldElement.blip);
		g_heldElement = nil;
		
		PlaySoundFrontend(-1, 'Place_Prop_Success', 'DLC_Dmod_Prop_Editor_Sounds', 1);
	end
end

-------------------------------------
--			SELECT ELEMENT
-------------------------------------
function selectElement(element)
	if (not g_selectedElement) then
		NetworkRequestControlOfEntity(element);
	
		g_selectedElement = {};
		g_selectedElement.element = element;
		g_selectedElement.dim1, g_selectedElement.dim2 = GetModelDimensions(GetEntityModel(g_selectedElement.element));
		g_selectedElement.markerHeight = math.max(g_selectedElement.dim1.z, g_selectedElement.dim2.z) + 1.4;
		g_selectedElement.offset = math.max(g_selectedElement.dim2.x-g_selectedElement.dim1.x, g_selectedElement.dim2.y-g_selectedElement.dim1.y) + 1.4;
		
		g_selectedElement.blip = AddBlipForEntity(g_selectedElement.element);
		SetBlipSprite(g_selectedElement.blip, 615);
		SetBlipDisplay(g_selectedElement.blip, 8);
		SetBlipScale(g_selectedElement.blip, 0.9);
		SetBlipColour(g_selectedElement.blip, 5);
		--SetBlipAsShortRange(info.blip, true);
		BeginTextCommandSetBlipName("STRING");
		AddTextComponentString("Selected Object");
		EndTextCommandSetBlipName(g_selectedElement.blip);
	end
end

function deselectElement()
	if (g_selectedElement) then
		if (elementProprties.enabled) then
			return false;
		end
		--SetEntityCollision(g_selectedElement.element, true, true);
		RemoveBlip(g_selectedElement.blip);
		g_selectedElement = nil;
	end
end

-------------------------------------
--		ELEMENT DOUBLE CLICK
-------------------------------------
function onElementDoubleClick(element)
	local editorElement = getEditorEntity(element);
	if (editorElement) then
		local theEdf = edfGet(editorElement.edf);
		local elementData = edfGetElementData(theEdf, editorElement.elementType);
	
		openElementProperties(element, elementData);
	end
end