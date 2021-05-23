RegisterNetEvent('mapeditor_getmaps');
AddEventHandler('mapeditor_getmaps',
function(action)
	TriggerClientEvent('mapeditor_returnmaps', source, action, exports.mapmanager:getMaps());
end)