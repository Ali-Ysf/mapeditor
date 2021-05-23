RegisterNUICallback('ontopmenuclick',
function(data, cb)
	local action = data.action;
	if (action == 'new') then
		TriggerServerEvent('newMap');
	elseif (action == 'open') then
		TriggerServerEvent('mapeditor_getmaps', action);
	elseif (action == 'save') then
		TriggerServerEvent('mapeditor_getmaps', action);
	end
	
	cb({});
end);

RegisterNetEvent('mapeditor_returnmaps');
AddEventHandler('mapeditor_returnmaps',
function(action, _maps)
	local maps = {};
	for k,v in pairs(_maps) do
		table.insert(maps, k);
	end
	SendNUIMessage({
		type = 'topmenu',
		action = action,
		maps = maps
	})
end)

-- edf elements
RegisterNUICallback('onEdfElementClick',
function(data, cb)
	local theEdf = edfGet(data.resourceName);
	if ( not theEdf ) then
		print("invalid resource (doesn't match selected edfs)");
		-- invalid resource (doesn't match selected edfs)
		return false;
	end

	local edfElement = edfGetElementData(theEdf, data.edfElement);

	if (edfElement.shortcut) then
		if (edfElement.shortcut == 'model') then
			local edfElementData = edfIndexElementData(edfElement);
			initElementViewer(edfElement.type, edfElementData.model.default, function(elementModel)
				mapeditor_unfocus({});
				if (elementModel) then
					Citizen.Wait(100);
					doCreateElement(data.edfElement, data.resourceName, true, elementModel);
				end
			end);
		end
	else
		doCreateElement(data.edfElement, data.resourceName, true);
	end
	
	cb({});
end);

-- Save/Load Windows
RegisterNUICallback('onSLSubmit',
function(data, cb)
	if (not data.name) then
		cb({success=false, errormsg="Name can't be left empty"});
		return false;
	end
	if (#data.name == 0) then
		cb({success=false, errormsg="Name can't be left empty"});
		return false;
	end
	if (data.type == "save") then
		TriggerServerEvent("saveMap", data.name);
		cb({success=true, successmsg="Map save in progress..."});
		return true;
	elseif (data.type == "open") then
		TriggerServerEvent("loadMap", data.name);
		cb({success=true, successmsg="Map laod in progress..."});
		return true;
	end
	cb({});
end);