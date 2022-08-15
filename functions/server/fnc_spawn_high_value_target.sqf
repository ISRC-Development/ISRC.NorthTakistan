// File: functions\server\fnc_spawn_high_value_target.sqf

private _deployment = false;
private _attempts   = 0;
while {typeName _deployment == "BOOL" && _attempts <= 50} do {
	private _location = selectRandom (call fnc_getAllLocations);
	private _name     = _location select 0;
	if !(_name in (profileNamespace getVariable ["CAPTURED_SECTORS", []]) && (_location select 2) != "NameMarine") then {
		_deployment = _location;
	};
	_attempts = _attempts + 1;
};
if (typeName _deployment == "BOOL") exitWith {
	systemChat "HVT: No deployment location found, exiting...";	
};

private _destination = false;
_attempts    		 = 0;
while {typeName _destination == "BOOL" && _attempts <= 50} do {
	private _location = selectRandom (call fnc_getAllLocations);
	private _name     = _location select 0;
	_destination = _location;
	_attempts = _attempts + 1;
};
if (typeName _destination == "BOOL") exitWith {
	systemChat "HVT: No destination location could be found! Exiting...";	
};

private _bounty    = selectRandom[750000, 1000000, 1500000];
private _bounty_notation = [_bounty] call fnc_standardNotation;
private _unitClass = selectRandom ISRC_civilians;
private _vehClass  = selectRandom ISRC_civilian_vehicles;
private _action    = "spawn_civilian_motorist";
private _pos       = [_deployment select 1, 1, 150, 2, 0, 25, 0] call BIS_fnc_findSafePos;
private _vehicle   = _vehClass createVehicle _pos;
private _group     = createGroup civilian;
private _hvt       = _group createUnit [_unitClass, [ _pos, [2, 2, 0] ] call BIS_fnc_vectorAdd, [], 0, "NONE"];

private "_id"; // Female identities
if ("Female" in (typeOf _hvt)) then {
	// is female
	private _id = [false, selectRandom[0, 1, 2]] call fnc_randomIdentity;
	_hvt setIdentity _id;
	[_hvt, _id] remoteExec ["setIdentity", 0, _hvt];	
} else {
	// is male
};

_hvt moveInDriver _vehicle;

["Intel", [format ["HVT: %1 DST: %2 PRC: $%3", name _hvt, _destination select 0, _bounty_notation]]] remoteExec ["BIS_fnc_showNotification"];

private _hvt_marker_name = format["hvt_marker_%1", [6] call fnc_genId]; 
private _marker = createMarker [_hvt_marker_name, getPos _hvt];
_marker setMarkerType "selector_selectedMission";
_marker setMarkerColor "ColorGreen";

private _nameSave = name leader _group;

private _hvt_gvar = format["hvt_%1", [6] call fnc_genId]; // Bool: was HVT deleted due to time?
missionNamespace setVariable [_hvt_gvar, false];

[_hvt, _hvt_gvar] spawn {
	private _hvt = _this select 0;
	private _hvt_gvar = _this select 1;
	sleep selectRandom[500, 800, 1000];
	if (alive _hvt) then {
		deleteVehicle _hvt;
		missionNamespace setVariable [_hvt_gvar, true];
	};
};

while {count (units _group select {alive _x}) > 0} do {

	_marker setMarkerPos getPos leader _group;
	_marker setMarkerText format["HVT - %1 - %2 - $%3", _nameSave, mapGridPosition leader _group, _bounty_notation];
	
	_group move (_destination select 1);
	_group setFormDir (leader _group getDir (_destination select 1));
	_group setSpeedMode "FULL";

	sleep 20;
};

deleteMarker _hvt_marker_name;

if (missionNamespace getVariable [_hvt_gvar, false] == false) then {
	["IntelGreen", [
		format["High-Value Target %1 Has Been Neutralized!", _nameSave]
	]] remoteExec ["BIS_fnc_showNotification"];

	[_bounty] call fnc_addToFunding;
	["IntelGreen", [
		format["New Funding: <br/>$%1", _bounty_notation]
	]] remoteExec ["BIS_fnc_showNotification"];
};


/*
_hvt addEventHandler ["Killed", {
	params ["_unit", "_killer", "_instigator", "_useEffects"];
	if (side _killer == WEST) then {
		["IntelGreen", [
			format["High-Value Target %1 Has Been Neutralized!", _nameSave]
		]] remoteExec ["BIS_fnc_showNotification"];

		[_bounty] call fnc_addToFunding;
		["IntelGreen", [
			format["New Funding: <br/>$%1", _bounty_notation]
		]] remoteExec ["BIS_fnc_showNotification"];		
	};
}];

*/