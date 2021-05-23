local function isMap(resourceName)
	local type = GetResourceMetadata(resourceName, 'resource_type', 0);
	return type == 'map';
end

local function prepareResourcePath(path)
	local startsAt = path:find('resources');
	if (startsAt) then
		return path:sub(startsAt, #path):gsub("//", "/");
	end
	return false;
end

---------------------
-- NEW
---------------------
function newMap()
	eraseEditorElements();
	MAPEDITOR.loadedMap = nil;
	MAPEDITOR.info = {
		resource = nil,
		author = nil,
		version = nil,
		description = nil,
		friendlyName = nil
	};
end
RegisterNetEvent('newMap');
AddEventHandler('newMap', newMap);

---------------------
-- LOAD(OPEN)
---------------------
function loadMap(resourceName)
	
end
RegisterNetEvent('loadMap');
AddEventHandler('loadMap', loadMap);

---------------------
-- SAVE
---------------------
local function createElementAttributesForSaving(element, data)
	local str = "";
	
	local theEdf = edfGet(data.edf);
	
	if ( not theEdf ) then
		print("invalid resource (doesn't match selected edfs)");
		-- invalid resource (doesn't match selected edfs)
		return false;
	end
	
	local edfElement = edfGetElementData(theEdf, data.elementType);
	
	if ( not edfElement ) then
		print("invalid element (element does not exists in selected edfs)");
		-- invalid element (element does not exists in selected edfs)
		return false;
	end
	
	str = str .. edfElement.name .. ' "'.. data.modelName ..'" { ';
	
	for i=1, #edfElement.data do
		print(edfElement.type, edfElement.data[i].name);
		if (edfElements[edfElement.type] and edfElements[edfElement.type].properties[edfElement.data[i].name] and edfElements[edfElement.type].properties[edfElement.data[i].name].getValue) then
			print('value found');
			local value = edfElements[edfElement.type].properties[edfElement.data[i].name].getValue(element);
			if (value) then
				if (edfElement.data[i].name == "position") then
					str = str .. "x=" .. value[1] .. ", y=" .. value[2] .. ", z=" .. value[3];
				elseif (edfElement.data[i].name == "rotation") then
					str = str .. "rx=" .. value[1] .. ", ry=" .. value[2] .. ", rz=" .. value[3];
				else
					str = str .. edfElement.data[i].name .. "=" .. value;
				end
				
				str = str .. ", ";
			end
		end
	end
	
	str = str:sub(1, -3) .. " }\n";
	return str;
end

function saveMap(resourceName, test)
	doMapSave(resourceName, test, source);
end
RegisterNetEvent('saveMap');
AddEventHandler('saveMap', saveMap);

function doMapSave(resourceName, test, savedBy)
	local resourcePath = GetResourcePath(resourceName);
	local workingPath = "resources/[editor]/[Maps]/".. resourceName;
	if (resourcePath) then -- map exists with the same name
		if (not isMap(resourceName)) then
			-- Can't overwrite non-map resource
			return false
		end
		workingPath = prepareResourcePath(resourcePath);
		print(workingPath);
		os.execute("rmdir /s /q "..workingPath:gsub("/","\\\\")); -- Remove the resource directory to be overwritten. Starts fresh lol
		os.execute("if not exist ".. workingPath:gsub("/","\\\\") .." mkdir "..workingPath:gsub("/","\\\\")); -- re-create the resource directory
	else
		os.execute("if not exist resources\\[editor]\\[Maps] mkdir resources\\[editor]\\[Maps]"); -- create maps directory if not exists
		os.execute("if not exist resources\\[editor]\\[Maps]\\".. resourceName .." mkdir resources\\[editor]\\[Maps]\\"..resourceName); -- create new resource directory
	end
	workingPath = workingPath.."/";
	
	-- Create fxmanifest.lua
	local fxmanifest = "";
	
	if (MAPEDITOR.info.author) then
		fxmanifest = fxmanifest .. "author '".. MAPEDITOR.info.author .."'\n";
	end
	if (MAPEDITOR.info.version) then
		fxmanifest = fxmanifest .. "version '".. MAPEDITOR.info.version .."'\n";
	end
	if (MAPEDITOR.info.description) then
		fxmanifest = fxmanifest .. "description '".. MAPEDITOR.info.description .."'\n";
	end
	fxmanifest = fxmanifest .. "repository 'https://github.com/ALw7sH/mapeditor'\n";
	
	fxmanifest = fxmanifest .. "\n";
	
	fxmanifest = fxmanifest .. "resource_type 'map' { gameTypes = { ['basic-gamemode'] = true } }\n";
	fxmanifest = fxmanifest .. "map 'map.lua'\n";
	fxmanifest = fxmanifest .. "fx_version 'adamant'\n";
	fxmanifest = fxmanifest .. "game 'gta5'\n";
	
	local fxmanifestFile = io.open( workingPath.."/fxmanifest.lua", "a"); 
	if (fxmanifestFile) then
		fxmanifestFile:write(fxmanifest);
		fxmanifestFile:close();
	end
	
	-- Create map.lua
	local map = "";
	
	for k,v in pairs(MAPEDITOR.elements) do
		local str = createElementAttributesForSaving(k, v);
		if (str) then
			map = map .. str;
		end
	end
	
	local mapFile = io.open( workingPath.."/map.lua", "a"); 
	if (mapFile) then
		mapFile:write(map);
		mapFile:close();
	end
end

function quickSaveMap()
	
end

function doQuickSaveMap()
	
end

--[[
os.execute( "rmdir /s /q resources\\maps" ) REMOVE DIRECTORY (WITH ALL CHILDREN)
os.execute( "mkdir resources\\maps" ); CREATE DIRCTORY

CREATE FILE
local file = io.open( "resources\\maps\\test22.map", "a"); 
print(file);
if (file) then
	file:write("-- End of the test.lua file");
	file:close();
end
]]