local keys={
	["arrow_up"]=27, ["E"]=46, ["M"]=244, ["T"]=245, ["L"]=7, ["Y"]=246, ["X"]=77, ["G"]=47, ["U"]=303, ["Z"]=20,
	["N"]=249, ["W"]=32, ["F9"]=56, ["K"]=311, ["2"]=158, ["6"]=159, ["S"]=33, ["3"]=160, ["F"]=49, ["F10"]=57,
	["8"]=162, ["B"]=29, ["A"]=34, ["4"]=164, ["5"]=165, ["F5"]=166, ["F6"]=167, ["P"]=199, ["F7"]=168, ["LShift"]=21,
	["F3"]=170, ["C"]=26, ["D"]=30, ["9"]=163, ["Q"]=44, ["7"]=161, ["arrow_down"]=173, ["1"]=157, ["arrow_left"]=174,
	["F11"]=344, ["arrow_right"]=175, ["V"]=0, ["R"]=45, ["F1"]=288, ["LAlt"]=19, ["H"]=74, ["F2"]=289, ["["]=39
};
--[[local keys_check={
	[34]="A", [29]="B", [26]="C", [30]="D", [46]="E", [49]="F", [47]="G", [74]="H", [311]="K", [7]="L", [244]="M", [249]="N", [199]="P", [44]="Q",
	[33]="S", [245]="T", [303]="U", [0]="V", [32]="W", [77]="X", [246]="Y", [20]="Z", [39]="[", [27]="UpArr", [173]="DownArr", [174]="LeftArr",
	[175]="RightArr", [19]="LAlt", [168]="F7", [288]="F1", [289]="F2", [170]="F3", [166]="F5", [167]="F6", [56]="F9", [57]="F10", [45]="R",
	[344]="F11", [157]="1", [158]="2", [160]="3", [164]="4", [165]="5", [159]="6", [161]="7", [162]="8", [163]="9", [21]="LShift"
};]]

local addedCommands = {};
local commandState = {};
local keyStateToBool = { down = true, up = false };
local keybinds = {};
local keybinds_backup = {};
local keyStates = { down = true, up = true, both = true };

function bindControl ( control, keyState, handlerFunction, ... )
	if not keyStates[keyState] then return false end
	if not control then return false end
	control = string.lower(control);
	if not keys[control] then return false end
	local theKey = keys[control];
	
	keybinds[theKey] = {
		key = control,
		keyState = keyState,
		handlerFunction = handlerFunction,
		args = {...}
	};
end


function unbindControl ( control, keyState, handlerFunction )
	if not control then return false end
	--Handle the optional arguments just like bindKey
	if keyState then
		if handlerFunction then
			--The control may not be necessarilly be binded
			if ( keybinds[control] ) then
				if ( keybinds[control][keyState] ) then
					keybinds[control][keyState][handlerFunction] = nil
				end
			end
		else
			if ( keybinds[control] ) then
				keybinds[control][keyState] = nil
			end
		end
	else
		keybinds[control] = nil
	end
	return true
end

function getCommandState ( command )
	return commandState[command]
end

local ci_IsDisabledControlJustPressed = IsDisabledControlJustPressed;
Citizen.CreateThread(
function()
	while true do
		Wait(1);
		for k,v in pairs(keybinds) do
			local isDown = ci_IsDisabledControlJustPressed(1, k);
			local isUp = ci_IsDisabledControlJustPressed(1, k);
			if (v.keyState == 'down') then
				
			end
		end
	end
end);