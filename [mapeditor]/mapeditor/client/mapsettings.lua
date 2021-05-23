updateMapSettings = {
	edf = function(edf)
		SendNUIMessage({
			type = 'updateInterface',
			section = 'mapSettings',
			data = 'edf',
			value = edf,
		});
	end,
}

