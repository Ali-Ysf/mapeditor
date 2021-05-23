function loadMapEditorSettings()
	restoreMapEditorSettings();
	for k,v in pairs(MAPEDITOR_SETTINGS) do
		local dataType = type(v);
		
		if (dataType == 'boolean') then
			local value = GetResourceKvpString(k);
			if (value) then
				MAPEDITOR_SETTINGS[k] = toBool(value);
			end
		elseif (dataType == 'number') then
			local value = GetResourceKvpFloat(k);
			if (value) then
				MAPEDITOR_SETTINGS[k] = value;
			end
		end
	end
	
	exports.freecam:setFreecamOption('normalSpeed', MAPEDITOR_SETTINGS.camera_speed_normal);
	exports.freecam:setFreecamOption('fastSpeed', MAPEDITOR_SETTINGS.camera_speed_fast);
	exports.freecam:setFreecamOption('slowSpeed', MAPEDITOR_SETTINGS.camera_speed_slow);
	exports.freecam:setFreecamOption('lookSensitivity', MAPEDITOR_SETTINGS.camera_look_sensitivity);
end

function saveMapEditorSettings()
	for k,v in pairs(MAPEDITOR_SETTINGS) do
		local dataType = type(v);
		
		if (dataType == 'boolean') then
			SetResourceKvp(k, tostring(v));
		elseif (dataType == 'number') then
			if (v%1 == 0) then
				SetResourceKvpFloat(k, v*1.0);
			else
				SetResourceKvpFloat(k, v);
			end
		end
	end
	
	exports.freecam:setFreecamOption('normalSpeed', MAPEDITOR_SETTINGS.camera_speed_normal);
	exports.freecam:setFreecamOption('fastSpeed', MAPEDITOR_SETTINGS.camera_speed_fast);
	exports.freecam:setFreecamOption('slowSpeed', MAPEDITOR_SETTINGS.camera_speed_slow);
	exports.freecam:setFreecamOption('lookSensitivity', MAPEDITOR_SETTINGS.camera_look_sensitivity);
end

function restoreMapEditorSettings()
	MAPEDITOR_SETTINGS = deepcopy(MAPEDITOR_SETTINGS_DEFAULT);
end

RegisterNUICallback('requestMapEditorSettings',
function(data, cb)
	cb(MAPEDITOR_SETTINGS);
end);

RegisterNUICallback('restoreMapEditorSettings',
function(data, cb)
	cb(MAPEDITOR_SETTINGS_DEFAULT);
end);

RegisterNUICallback('saveMapEditorSettings',
function(data, cb)
	for k,v in pairs(data) do
		MAPEDITOR_SETTINGS[k] = v;
	end
	saveMapEditorSettings();
	cb({});
end);