const toastContainer = document.querySelector('.toaster-container');
var allowUnfocus = true;
var updateInterface = {};

function a7Call(name, data, cb){
	fetch(`https://${GetParentResourceName()}/`+name, {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json; charset=UTF-8',
		},
		body: JSON.stringify(data)
	})
	.then(resp => resp.json())
	.then(resp => {
		if (cb)
			cb(resp);
	})
	.catch(error => console.log(error));
}

function loadJSON(path, callback) {   
  var xobj = new XMLHttpRequest();
  xobj.overrideMimeType("application/json");
  xobj.open('GET', 'nui://mapeditor/'+path, true);
  xobj.onreadystatechange = function () {
    if (xobj.readyState == 4 && xobj.status == "200") {
      callback(JSON.parse(xobj.responseText));
    }
  };
  xobj.send(null);  
}

/*
	ALw7sH toast(er)
*/
var toasts = [];
function createToast(txt='', delay=5000){
	let toastData = {
		id: toasts.length,
	};
	
	let toastElem = document.createElement('div');
	toastElem.className = "toaster text-white bg-dark show";
	toastElem.id = 'toast-'+toastData.id;
	toastElem.innerHTML = `<div class="toaster-header bg-dark">
      <strong class="me-auto">A7 Map Editor</strong>
      <button type="button" onclick="destroyToast(${toastData.id})" class="btn-close" aria-label="Close"></button>
    </div>
    <div class="toaster-body">
      ${txt}
    </div>`;
	toastContainer.prepend(toastElem);
	
	toastData.elem = toastElem;
	
	toastData.destroyTimer = setTimeout(() => {
		destroyToast(toastData.id);
	}, delay);
	
	toasts.push(toastData);
}
function destroyToast(toastId){
	let toastData = toasts.find(obj => {
						return obj.id === toastId;
					});
	
	if(typeof toastData.destroyTimer !== "undefined"){
		clearTimeout(toastData.destroyTimer);
	}
	toastData.elem.classList.remove('show');
	toastData.elem.ontransitionend = () => {
		toastData.elem.parentNode.removeChild(toastData.elem);
		toasts.splice(toasts.indexOf(toastData), 1);
	};
}

window.addEventListener('DOMContentLoaded', (event) => {
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
	var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
		return new bootstrap.Tooltip(tooltipTriggerEl)
	})

	for (let s in editorSettings.sliders) {
		editorSettings.sliders[s] = new Slider('#'+s, {});
	}
	
	elementBrowser.clusterize = new Clusterize({
		rows: [],
		scrollId: 'scrollArea',
		contentId: 'contentArea'
	});
	
	let scrollArea = document.getElementById('scrollArea');
	scrollArea.style.maxHeight = (document.documentElement.clientHeight - 41 - 36 - 48 - 50)+"px";
	
	loadObjects();
	loadVehicles();
});

function detectClose(event){
	let e = event || window.event;
    var charCode = (typeof e.which == "number") ? e.which : e.keyCode;
	if (charCode && String.fromCharCode(charCode) === "F") {
		if (allowUnfocus)
			a7Call('mapeditor_unfocus', {});
    }
}
document.addEventListener("keydown", detectClose);
window.addEventListener('message', (event) => {
    if (event.data.type === 'open') {
        document.addEventListener("keydown", detectClose);
    } else if (event.data.type === 'displayToast') {
		createToast(event.data.message, event.data.delay);
	} else if (event.data.type === 'topmenu'){
		if (event.data.action === 'open' || event.data.action === 'save') {
			insertMaps(event.data.maps);
		}
	} else if (event.data.type === 'elementViewer') {
		if (event.data.action == 'open') {
			elementViewer(event.data.elementType);
		}
	} else if (event.data.type === 'elementProperties') {
		if (event.data.action == 'open') {
			openElementPropMenu(event.data.data);
		}
	} else if (event.data.type == 'updateInterface') {
		updateInterface[event.data.section][event.data.data](event.data.value);
	}
});

/*
	TOP MENU
*/
const topMenuElm = document.querySelector('.topmenu-container');
const topMenu = {
	
}

function topmenuClick(ali){
	switch(ali){
		case 'new':
			a7Call('ontopmenuclick', {action: ali});
			break;
		case 'open':
			insertMaps(['Getting maps...']);
			openSLWindow(ali);
			a7Call('ontopmenuclick', {action: ali});
			break
		case 'save':
			insertMaps(['Getting maps...']);
			openSLWindow(ali);
			a7Call('ontopmenuclick', {action: ali});
			break
		case 'settings':
			openEditorSettings()
			break
		case 'undo':
			
			break
		case 'redo':
			
	}
}
/*
	EDITOR SETTINGS
*/
const editorSettingsMenu = document.querySelector('.editor-settings');
const editorSettings = {
	ok: editorSettingsMenu.querySelector('button:nth-of-type(1)'),
	cancel: editorSettingsMenu.querySelector('button:nth-of-type(2)'),
	restore: editorSettingsMenu.querySelector('button:nth-of-type(3)'),
	
	sliders: {
		'camera_speed_normal': true,
		'camera_speed_fast': true,
		'camera_speed_slow': true,
		'camera_look_sensitivity': true,
		'entity_movement_normal': true,
		'entity_movement_fast': true,
		'entity_movement_slow': true,
		'entity_rotation_normal': true,
		'entity_rotation_fast': true,
		'entity_rotation_slow': true
	},
	
	settings: {}
}

function updateEditorSettings(){
	let data = editorSettings.settings;
	for (let setting in data){
		let settingElement = editorSettingsMenu.querySelector('#'+setting);
		if (settingElement?.nodeName){
			if (settingElement.nodeName == 'INPUT'){
				if (settingElement.type == 'checkbox'){
					settingElement.checked = data[setting];
				} else {
					if (editorSettings.sliders[setting]){
						editorSettings.sliders[setting].setValue(data[setting]);
						continue;
					}
				}
			} else if (settingElement.nodeName == 'SELECT') {
				settingElement.value = String(data[setting]);
			}
		}
	}
}

function getEditorSettings(){
	let returnData = {};
	let data = editorSettings.settings;
	for (let setting in data){
		let settingElement = editorSettingsMenu.querySelector('#'+setting);
		if (settingElement?.nodeName){
			if (settingElement.nodeName == 'INPUT'){
				if (settingElement.type == 'checkbox'){
					returnData[setting] = settingElement.checked && true || false;
				} else {
					if (editorSettings.sliders[setting]){
						returnData[setting] = editorSettings.sliders[setting].getValue();
						continue;
					}
				}
			} else if (settingElement.nodeName == 'SELECT') {
				returnData[setting] = parseFloat(settingElement.value);
			}
		}
	}
	return returnData;
}

function openEditorSettings(){
	allowUnfocus = false;
	a7Call('requestMapEditorSettings', [],
	function(data){
		editorSettings.settings = data;
		updateEditorSettings();
		
		editorSettingsMenu.style.display = 'flex';
		topMenuElm.style.display = 'none';
		edfeMenu.style.display = 'none';
	});
}

function closeEditorSettings(){
	allowUnfocus = true;
	editorSettingsMenu.style.display = 'none';
	topMenuElm.style.display = 'flex';
	edfeMenu.style.display = 'block';
}

editorSettings.cancel.addEventListener('click',() => {
	closeEditorSettings();
});

editorSettings.ok.addEventListener('click',() => {
	a7Call('saveMapEditorSettings', getEditorSettings());
	closeEditorSettings();
});

editorSettings.restore.addEventListener('click',() => {
	a7Call('restoreMapEditorSettings', [],
	function(data){
		editorSettings.settings = data;
		updateEditorSettings();
	});
});
/*
	MAP SETTINGS
*/
const mapSettingsMenu = document.querySelector('.map-settings');
updateInterface.mapSettings = {};
const mapSettings = {
	ok: mapSettingsMenu.querySelector('button:nth-of-type(1)'),
	cancel: mapSettingsMenu.querySelector('button:nth-of-type(2)'),
	gamemode: {
		edfSelected: mapSettingsMenu.querySelector('#gamemode label strong'),
		edfTableBody: mapSettingsMenu.querySelector('#gamemode table tbody')
	}
}

function openMapSettings(){
	allowUnfocus = false;
	mapSettingsMenu.style.display = 'flex';
	topMenuElm.style.display = 'none';
	edfeMenu.style.display = 'none';
}

mapSettings.cancel.addEventListener('click',() => {
	allowUnfocus = true;
	mapSettingsMenu.style.display = 'none';
	topMenuElm.style.display = 'flex';
	edfeMenu.style.display = 'block';
});

updateInterface.mapSettings.edf = function(data){
	edfUpdateAvilable(data);
	
	if (data.selected)
		mapSettings.gamemode.edfSelected.innerHTML = 'Selected: '+data.selected.resource;
	else
		mapSettings.gamemode.edfSelected.innerHTML = 'Selected: None';
	
	mapSettings.gamemode.edfTableBody.innerHTML = 'Loading edf...';
	
	let ali = '';
	if (data.available.length > 0) {
		for (let i=0; i<data.available.length; i++){
			ali += `<tr>
											<td>${data.available[i].resource} <button type="button" class="btn btn-secondary btn-sm pull-right">SELECT</button></td>
										</tr>`;
		}
	} else {
		ali = `<tr>
											<td>No definitions found</td>
										</tr>`;
	}
	
	mapSettings.gamemode.edfTableBody.innerHTML = ali;
}

/*
	BOTTOM MENU (edf-elements)
*/
const edfeMenu = document.querySelector('.bottommenu-container');
var cacheEdfElements = {};
const edfe = {
	name: edfeMenu.querySelector('#edf-name'),
	elements: edfeMenu.querySelector('#edf-elements')
}

function bottomOnHover(){
	if (cacheEdfElements.selected)
		edfe.name.innerHTML = edfe.name.innerHTML+' (SCROLL TO CHANGE)';
}

function bottomOnLeave(){
	if (cacheEdfElements.selected){
		let ali = edfe.name.innerHTML.indexOf(' (SCROLL TO CHANGE)');
		if (ali > -1)
			edfe.name.innerHTML = edfe.name.innerHTML.substring(0, ali);
	}
}

function edfSelect(toSelect){
	let data = cacheEdfElements[toSelect];
	
	edfe.name.innerHTML = data.resource.toUpperCase();
	
	edfe.elements.innerHTML = '';
	
	let ali = '';
	for (let i=0; i<data.elements.length; i++){
		ali += `<span onclick="onEdfElementClick('${data.resource}', '${data.elements[i].name}')" class="icon" data-bs-toggle="tooltip" data-bs-placement="top" title="${data.elements[i].friendlyname}" aria-hidden="true"><i class="${data.elements[i].icon}" style="pointer-events: none;"></i></span>`;
	}
	
	edfe.elements.innerHTML = ali;
	
	var tooltipTriggerList = [].slice.call(edfe.elements.querySelectorAll('[data-bs-toggle="tooltip"]'))
	var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
		return new bootstrap.Tooltip(tooltipTriggerEl)
	})
}

function onEdfElementClick(resourceName, edfElement){
	a7Call('onEdfElementClick', {resourceName: resourceName, edfElement: edfElement});
}

function edfUpdateAvilable(data){
	cacheEdfElements.default = data.default;
	cacheEdfElements.selected = data.selected;
	
	edfSelect('default');
}

/*
	ELEMENT BRWOSER
*/
const elementBrowserMenu = document.querySelector('.element-viewer');
const elementBrowser = {
	search: elementBrowserMenu.querySelector("input"),
	table: elementBrowserMenu.querySelector("table"),
	
	data: {
		object: [],
		vehicle: [],
	},
	elementType: "object"
}

function loadObjects(){
	loadJSON("data/elementsList/object.json", data => {
		console.log(data.length);
		for (let i=0, ii=data.length; i<ii; i++){
			elementBrowser.data.object[i] = {
				value: data[i],
				markup: `<tr onclick="onModelSelect(this)" ><td>${data[i]}</td></tr>`
			};
		}
	});
}

function loadVehicles(){
	loadJSON("data/elementsList/vehicle.json", data => {
		console.log(data.length);
		for (let i=0, ii=data.length; i<ii; i++){
			elementBrowser.data.vehicle[i] = {
				value: data[i],
				markup: `<tr onclick="onModelSelect(this)" ><td>${data[i]}</td></tr>`
			};
		}
	});
}

function doSearch() {
	let searchTerm = elementBrowser.search.value;
	let result = [];
	for (let i=0, ii=elementBrowser.data[elementBrowser.elementType].length; i<ii; i++){
		if (elementBrowser.data[elementBrowser.elementType][i].value.includes(searchTerm))
			result.push(elementBrowser.data[elementBrowser.elementType][i].markup);
	}
	elementBrowser.clusterize.update(result);
}

function elementViewer(elementType){
	allowUnfocus = false;
	elementBrowserMenu.style.display = 'block';
	
	topMenuElm.style.display = 'none';
	edfeMenu.style.display = 'none';
	
	elementBrowser.elementType = elementType;
	
	doSearch();
}

function closeElementViewer(spawnObj=false){
	allowUnfocus = true;
	elementBrowserMenu.style.display = 'none';
	topMenuElm.style.display = 'flex';
	edfeMenu.style.display = 'block';
	elementBrowser.search.value = '';
	
	a7Call('destroyViewer', [spawnObj]);
}

function onModelSelect(elm){
	//allowUnfocus = true;
	a7Call('onModelSelect', [elm.firstChild.innerHTML]);
}

/*
	Save/Load Map WINDOW
*/
const slWindowElm = document.querySelector('.sl-window');
const slWindow = {
	header: slWindowElm.querySelector('.card-header'),
	table: slWindowElm.querySelector('table'),
		tbody: slWindowElm.querySelector('tbody'),
	input: slWindowElm.querySelector('input'),
	sbmt: slWindowElm.querySelector('button[name="submit"]'),
	cancel: slWindowElm.querySelector('button[name="cancel"]')
}

function openSLWindow(type){
	allowUnfocus = false;
	if (type === 'open'){
		slWindow.header.innerHTML = 'OPEN...';
		slWindow.sbmt.innerHTML = 'Open';
	} else if (type === 'save') {
		slWindow.header.innerHTML = 'SAVE...';
		slWindow.sbmt.innerHTML = 'Save';
	}
	
	topMenuElm.style.display = 'none';
	edfeMenu.style.display = 'none';
	slWindowElm.style.display = 'flex';
}

function insertMaps(maps){
	slWindow.tbody.innerHTML = `<tr>
			<td>Loading maps...</td>
		</tr>`;
	
	let mapshtml = '';
	for (let map of maps) {
		mapshtml += `<tr onclick='slWindow.input.value = this.children[0].innerHTML;' >
			<td>${map}</td>
			<td>None</td>
		</tr>`;
	}
	slWindow.tbody.innerHTML = mapshtml;
}

slWindow.cancel.addEventListener('click',() => {
	allowUnfocus = true;
	slWindowElm.style.display = 'none';
	topMenuElm.style.display = 'flex';
	edfeMenu.style.display = 'block';
});

slWindow.sbmt.addEventListener('click',() => {
	a7Call('onSLSubmit', {type:slWindow.sbmt.innerHTML.toLowerCase(), name:slWindow.input.value},
	function(data){
		if (data.success) {
			allowUnfocus = true;
			slWindowElm.style.display = 'none';
			topMenuElm.style.display = 'flex';
			edfeMenu.style.display = 'block';
			
			createToast(data.successmsg);
		} else {
			createToast(data.errormsg);
		}
	});
});

/*
	ELEMENT PROPERTIES
*/
const elementPropMenu = document.querySelector('.entityProp');
const elementProp = {
	header: elementPropMenu.querySelector(".card-header"),
	body: elementPropMenu.querySelector(".card-body"),
	
	ok: elementPropMenu.querySelector('.card-footer button:nth-of-type(1)'),
	cancel: elementPropMenu.querySelector('.card-footer button:nth-of-type(2)'),
}

var offset = [0,0];
var isDown = false;
elementProp.header.addEventListener('mousedown', function(e) {
    isDown = true;
    offset = [
        elementPropMenu.offsetLeft - e.clientX,
        elementPropMenu.offsetTop - e.clientY
    ];
}, true);

document.addEventListener('mouseup', function() {
    isDown = false;
}, true);

document.addEventListener('mousemove', function(event) {
    event.preventDefault();
    if (isDown) {
        mousePosition = {

            x : event.clientX,
            y : event.clientY

        };
        elementPropMenu.style.left = (mousePosition.x + offset[0]) + 'px';
        elementPropMenu.style.top  = (mousePosition.y + offset[1]) + 'px';
    }
}, true);

var elementPropApply = {};
elementPropApply.coord3d = function(name){
	let container = elementProp.body.querySelector('#'+name);
	
	let value = [
		Number(container.querySelector('input[name="x"]').value),
		Number(container.querySelector('input[name="y"]').value),
		Number(container.querySelector('input[name="z"]').value)
	];
	
	a7Call("onElementProprtiesChange", {name: name, value: value});
}

var elementPropAdd = {};
elementPropAdd.coord3d = function(name, coord=[0, 0, 0]){
	let aliysf = `<label class="form-label">${name.charAt(0).toUpperCase() + name.slice(1)}</label>
			<div class="mb-2" id="${name}">
				<div class="input-group input-group-sm mb-1">
					<span class="input-group-text">x</span>
					<input type="text" class="form-control" value="${coord[0]}" name="x" type="number" onchange="elementPropApply.coord3d('${name}')" oninput="elementPropApply.coord3d('${name}')" >
				</div>
				<div class="input-group input-group-sm mb-1">
					<span class="input-group-text">y</span>
					<input type="text" class="form-control" value="${coord[1]}" name="y" type="number" onchange="elementPropApply.coord3d('${name}')" oninput="elementPropApply.coord3d('${name}')" >
				</div>
				<div class="input-group input-group-sm">
					<span class="input-group-text">z</span>
					<input type="text" class="form-control" value="${coord[2]}" name="z" type="number" onchange="elementPropApply.coord3d('${name}')" oninput="elementPropApply.coord3d('${name}')" >
				</div>
			</div>`;
	elementProp.body.innerHTML += aliysf;
}
elementPropAdd.string = function(name, n="", disabled=false){
	let aliysf = `<label class="form-label">${name.charAt(0).toUpperCase() + name.slice(1)}</label>
				<div class="input-group input-group-sm mb-1" id="${name}">
					<input type="text" class="form-control" value="${n}" ${disabled && "disabled" || ""}>
				</div>`;
	elementProp.body.innerHTML += aliysf;
}
elementPropAdd.number = function(name, n=0){
	let aliysf = `<label class="form-label">${name.charAt(0).toUpperCase() + name.slice(1)}</label>
				<div class="input-group input-group-sm mb-1" id="${name}">
					<input type="text" class="form-control" value="${n}">
				</div>`;
	elementProp.body.innerHTML += aliysf;
}
elementPropAdd.integer = function(name, n=0){
	let aliysf = `<label class="form-label">${name.charAt(0).toUpperCase() + name.slice(1)}</label>
				<div class="input-group input-group-sm mb-1" id="${name}>
					<input type="text" class="form-control" value="${n}">
				</div>`;
	elementProp.body.innerHTML += aliysf;
}
elementPropAdd.selection = function(name, options){
	let aliysf = `<label class="form-label">${name.charAt(0).toUpperCase() + name.slice(1)}</label>
				<div class="input-group input-group-sm mb-1" id="${name}>
					<select class="form-select">`;
				for (let i=0; i<options.length; i++){
		aliysf +=	`<option>${options[i]}</option>`;
				}
		aliysf =	`</select>
				</div>`;
	elementProp.body.innerHTML += aliysf;
}

function openElementPropMenu(proprties){
	//allowUnfocus = false;
	
	elementProp.body.innerHTML = '';
	
	for (let data of proprties){
		if (elementPropAdd[data.type]) {
			elementPropAdd[data.type](data.name, data.value, data.disabled == 'true');
		}
	}
	
	topMenuElm.style.display = 'none';
	edfeMenu.style.display = 'none';
	elementPropMenu.style.display = 'flex';
}

elementProp.cancel.addEventListener('click',() => {
	//allowUnfocus = true;
	elementPropMenu.style.display = 'none';
	topMenuElm.style.display = 'flex';
	edfeMenu.style.display = 'block';
	
	a7Call('onElementPropertiesCancel', []);
});

elementProp.ok.addEventListener('click',() => {
	//allowUnfocus = true;
	elementPropMenu.style.display = 'none';
	topMenuElm.style.display = 'flex';
	edfeMenu.style.display = 'block';
	
	a7Call('onElementPropertiesApply', []);
});