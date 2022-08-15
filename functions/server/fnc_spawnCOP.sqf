/*
server\compositions\ + CURRENT_FOP_TYPE
[getPos player] execVM "functionsServer.sqf";
*/

/*
Grab data:
Mission: front_defence
World: WL_Rosche
Anchor position: [6491.5, 13964.6]
Area size: 150
Using orientation of objects: no
*/

deleteMarker "cop_marker";

{
	if (_x getVariable["IS_COP", false] == true) then {
		deleteVehicle _x;
	};
} forEach allmissionobjects "";

params["_pos", ["_already_paid", false]];

_items = [
	["B_Slingload_01_Ammo_F",[7.56396,-1.83594,0.000869751],347.743,1,0,[],"","this setVariable ['IS_COP', true, true];",true,false], 
	["B_supplyCrate_F",[-6.37646,-1.41797,3.8147e-005],346.051,1,0,[],"","this setVariable ['IS_COP', true, true];",true,false], 
	[LOGI_POINT_CLASSNAME,[6.48438,8.8916,0],347.416,1,0,[],"","this setVariable ['IS_COP', true, true];",true,false], 
	["Land_Cargo_House_V1_F",[-8.02979,4.33398,0.00606537],257.109,1,0,[],"","this setVariable ['IS_COP', true, true];",true,false], 
	["Land_HBarrier_01_line_5_green_F",[-9.13867,-2.29785,-0.000110626],257.989,1,0,[],"","this setVariable ['IS_PROP', true, true];this setVariable ['IS_COP', true, true];",true,false], 
	["CUP_A2_Road_mud_0_2000",[-2.14355,15.332,0],167.03,1,0,[],"","this setVariable ['IS_PROP', true, true];this setVariable ['IS_COP', true, true];",true,false], 
	["B_Slingload_01_Fuel_F",[8.88574,-7.9834,0.000637054],168.257,1,0,[],"","this setVariable ['IS_COP', true, true];",true,false], 
	["Land_HBarrier_01_line_5_green_F",[-7.8667,-7.99121,-0.000221252],257.991,1,0,[],"","this setVariable ['IS_PROP', true, true];this setVariable ['IS_COP', true, true];",true,false], 
	["CUP_A2_Road_mud_0_2000",[1.72363,-1.68164,0],167.028,1,0,[],"","this setVariable ['IS_PROP', true, true];this setVariable ['IS_COP', true, true];",true,false], 
	["Land_HBarrier_01_line_5_green_F",[-11.8906,9.67871,-0.000156403],257.991,1,0,[],"","this setVariable ['IS_PROP', true, true];this setVariable ['IS_COP', true, true];",true,false], 
	["Land_HBarrier_01_line_5_green_F",[-6.57129,-13.6865,-0.000209808],257.984,1,0,[],"","this setVariable ['IS_PROP', true, true];this setVariable ['IS_COP', true, true];",true,false], 
	["Land_HBarrier_01_line_5_green_F",[-13.1929,15.3672,-0.000156403],257.991,1,0,[],"","this setVariable ['IS_PROP', true, true];this setVariable ['IS_COP', true, true];",true,false], 
	["CUP_A2_Road_mud_0_2000",[-5.99805,32.3223,0],167.03,1,0,[],"","this setVariable ['IS_PROP', true, true];this setVariable ['IS_COP', true, true];",true,false], 
	["Land_HBarrier_01_line_5_green_F",[-14.4653,21.0703,-0.000133514],257.99,1,0,[],"","this setVariable ['IS_PROP', true, true];this setVariable ['IS_COP', true, true];",true,false], 
	["CUP_A2_Road_mud_0_2000",[5.58057,-18.542,0],167.03,1,0,[],"","this setVariable ['IS_PROP', true, true];this setVariable ['IS_COP', true, true];",true,false]
];

if (typeName (profileNameSpace setVariable ["COP_LOCATION", false]) != "BOOL") then {
	["Intel", ["Forward Outpost has been moved."]] remoteExec ["BIS_fnc_showNotification"];
} else {
	["Intel", ["Forward Outpost has been deployed."]] remoteExec ["BIS_fnc_showNotification"];
};

profileNameSpace setVariable ["COP_LOCATION", [_pos select 0, _pos select 1, _pos select 2]];
missionNameSpace setVariable ["COP_LOCATION", [_pos select 0, _pos select 1, _pos select 2], true];

if !(_already_paid) then {
	[COP_DEPLOY_MOVE_PRICE] call fnc_subtractFunding;
	["Intel", [format ["HQ: Deployed FLP for %1 near %2.", 
	format["$%1", [COP_DEPLOY_MOVE_PRICE] call fnc_standardNotation],
	nearestLocation [_pos, ""]
	]]] remoteExec ["BIS_fnc_showNotification"];
};

[_pos, 0, _items, 0] call BIS_fnc_objectsMapper;

private _marker = createMarker ["cop_marker", [_pos select 0, _pos select 1]]; // Not visible yet.
_marker setMarkerType "hd_flag"; // Visible.
_marker setMarkerColor "ColorYellow"; // Blue.
_marker setMarkerText "FLP Alpha"; // Text.

publicVariable "COP_LOCATION";

