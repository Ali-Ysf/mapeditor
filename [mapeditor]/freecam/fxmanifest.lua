fx_version 	'cerulean'
game 		'gta5'

version 	'1.0.0'
author 		'ALw7sH <https://aliysf.com/>'

server_scripts {
	'freecam_server.lua'
}

client_scripts {
	'freecam.lua'
}

exports {
	'setFreecamEnabled',
	'setFreecamDisabled',
	'setFreecamPosition',
	'setFreecamRotation',
	'getFreecamPosition',
	'getFreecamRotation',
	'getFreecamMatrix',
	'getFreecamCam',
	'isFreecamEnabled',
	'getFreecamOption',
	'setFreecamOption'
}