fx_version 	'cerulean'
game 		'gta5'

version 	'1.0.0'
author 		'ALw7sH <https://aliysf.com/>'

--resource_type 'gametype' { name = 'A7_MultiGamemode' }

ui_page('html/index.html')

edf 'edf/edf.edf'

files {
	'html/clusterizejs/clusterize.css',
	'html/clusterizejs/clusterize.js',
	'html/index.html',
	'html/style.css',
	'html/script.js',
	'data/ObjectList.ini',
	'data/ObjectList.json',
	'data/img/crosshair.png',
	'data/img/object.png',
	'client/crosshair.png',
	'crosshair.png'
}

server_scripts {
	'server/globals.lua',
	'edf/edf_shared.lua',
	'edf/edf.lua',
	'server/elementmanager.lua',
	'server/saveload.lua',
	'server/main.lua'
}

client_scripts {
	'config.lua',
	'edf/edf_shared.lua',
	'client/utils.lua',
	'edf/edf_client.lua',
	'client/mapsettings.lua',
	'client/settings.lua',
	'client/elementproperties.lua',
	'client/move_cursor.lua',
	'client/elementcreation.lua',
	'client/elementviewer.lua',
	'client/interface.lua',
	'client/main.lua'
}

dependencies {
    'freecam',
}
