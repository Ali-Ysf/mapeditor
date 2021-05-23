MAPEDITOR = {};
MAPEDITOR.isFocus = false;

function mapeditor_unfocus(data, cb)
	if (MAPEDITOR.isFocus) then
		MAPEDITOR.isFocus = false;
		SetNuiFocus(false, false);
		
		toggleCrosshair(true);
	end
	if (cb) then cb({}); end
end
RegisterNUICallback('mapeditor_unfocus', mapeditor_unfocus);


function mapeditor_focus()
	if (not MAPEDITOR.isFocus) then
		MAPEDITOR.isFocus = true;
		toggleCrosshair(false);
		SetNuiFocus(true, true);
		SendNUIMessage({
			type = 'open',
		});
	end
end
RegisterCommand('+mapeditor_focus', mapeditor_focus, false)

RegisterCommand('-mapeditor_focus',
function()
	-- STOP PRINTING THIS SHIT IN CHAT!!!!
end, false)
RegisterKeyMapping('+mapeditor_focus', 'Map Editor Show Cursor', 'keyboard', 'f');

AddEventHandler('onResourceStart',
function(resource)
	if (GetCurrentResourceName() ~= resource) then
		return false;
	end
	
	--exports.freecam:setFreecamEnabled(); --104, -1940, 24
	--Citizen.Wait(500)
	--exports.freecam:setFreecamPosition(104, -1940, 24);
end)

AddEventHandler('onResourceStop',
function(resource)
	if (GetCurrentResourceName() ~= resource) then
		return false;
	end
	
	if (MAPEDITOR.isFocus) then
		SetNuiFocus(false, false);
	end
	
	viewElement_onResourceStop();
	--elementcreation_onResourceStop();
	exports.freecam:setFreecamDisabled();
end)


-- notify scripts that player is ready
Citizen.CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Citizen.Wait(0)
	end
	loadMapEditorSettings();
	exports.spawnmanager:spawnPlayer({
		x = 104.0, y = -1940.0, z = 24.0,
		heading = 0.0,
		model = 'a_m_m_farmer_01',
		skipFade = false,
	}, function()
		MAPEDITOR.camera = exports.freecam:setFreecamEnabled();
		
		TriggerEvent("onClientMapEditorPlayerReady");
		TriggerServerEvent("onMapEditorPlayerReady");
	end);
	--MAPEDITOR.camera = exports.freecam:setFreecamEnabled();
	
	--TriggerEvent("onClientMapEditorPlayerReady");
	--TriggerServerEvent("onMapEditorPlayerReady");
end)