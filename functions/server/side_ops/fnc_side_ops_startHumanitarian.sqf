params["_start_location"];

private _humanitarianSector = false;
private _cancel_op = false;
while {typeName _humanitarianSector == "BOOL"} do {
	private _location = selectRandom (call fnc_getAllLocations);
	if !(isNil "_location") then {
		private _name     = _location select 0;
		if (_name in (profileNamespace getVariable ["CAPTURED_SECTORS", []]) && (_location select 2) != "NameMarine") then {
			_humanitarianSector = _location;
		};
	};
};

private _target_name = _humanitarianSector select 0;
private _target_pos  = _humanitarianSector select 1;

HUMANITARIAN_RUNNING = true;

private _markermanager = [];
private _time = SIDE_OP_HUMANITARIAN_ELAPSED_TIME;

private _marker = createMarker ["mission_events_marker", [0, 500, 0]];
_marker setMarkerColor "ColorWhite";
_marker setMarkerType "mil_dot";
_marker setMarkerSize [2, 2];
_marker setMarkerText "Side Ops:";
_markermanager pushBack _marker;

private _missionMarker = createMarker ["mission_marker", [0, 400, 0]];
_missionMarker setMarkerColor "ColorWhite";
_missionMarker setMarkerType "mil_dot";
_missionMarker setMarkerSize [2, 2];
_missionMarker setMarkerText format["Humanitarian Mission near %1. Time Left: %2", _target_name, format["%1", [((_time)/60)-.01,"HH:MM:SS"] call BIS_fnc_timetostring]];
_markermanager pushBack _missionMarker;

private _crate = "Box_NATO_Equip_F" createVehicle _start_location;
clearItemCargoGlobal     _crate;
clearWeaponCargoGlobal   _crate;
clearMagazineCargoGlobal _crate;
clearBackpackCargoGlobal _crate;       

_crate addItemCargoGlobal ["ACE_Humanitarian_Ration", 50];

private _road = [_start_location, 1000] call BIS_fnc_nearestRoad;

private _lz_marker = createMarker ["lz_marker", getPos _road];
_lz_marker setMarkerColor "ColorYellow";
_lz_marker setMarkerType "hd_start";
_lz_marker setMarkerSize [1, 1];
_lz_marker setMarkerText "Start Convoy";
_markermanager pushBack _lz_marker;

private _target_marker = createMarker ["target_marker", _target_pos];
_target_marker setMarkerType "Select";
_target_marker setMarkerSize [1, 1];
_target_marker setMarkerColor "ColorGreen";
_target_marker setMarkerText "Humanitarian Mission";
_markermanager pushBack _target_marker;

private _managedememies   = [];
private _managedcivilians = [];
private _trip_distance  = _start_location distance2D _target_pos;

private _transport_veh    = ISRC_transport_truck createVehicle _target_pos;
for "_i" from 0 to (selectRandom [1, 2, 3]) do {
	private _tgroup = createGroup EAST;
	private _tpos   = [_target_pos, 1, 300, 1, 0, 25, 0, [], []] call BIS_fnc_findSafePos;
	for "_i" from 0 to 12 do {
		private _u = _tgroup createUnit [selectRandom ISRC_transport_troops, _tpos, [], 100, "NONE"];
		_u moveInAny _transport_veh;
		[_u] call fnc_setRandomIdentity;
	};	
	[_tgroup] call fnc_aggressive_ai;
};

for "_i" from 0 to (MAX_CIV_POP_PEDS + 10) do {
	[_target_pos] spawn {
		params["_poss"];
		[_poss, false] execVM "functions\server\fn_civ_pop_manager.sqf";
	};
};

for "_i" from 0 to MAX_CIV_POP_TRAFFIC do {
	[_target_pos] spawn {
		params["_poss"];
		[_poss, true] execVM "functions\server\fn_civ_pop_manager.sqf";
	};
};

["Intel", [format ["Humanitarian Mission: %1", _target_name]]] remoteExec ["BIS_fnc_showNotification"];

sleep 10;

{
	if (side _x == civilian) then {
		_managedcivilians pushBack _x;
	};
} forEach allUnits;

private _civimarkers = [];

while {_time > 0 && !_cancel_op && (count allPlayers > 0)} do {
	
	_time = _time - 1;
	_missionMarker setMarkerText format["Humanitarian Mission near %1. Time Left: %2", _target_name, format["%1", [((_time)/60)-.01,"HH:MM"] call BIS_fnc_timetostring]];
	sleep 1;
	
	// remove dead ememies from manager
	private "_closest_player";
	private _playerList = allPlayers apply {[_target_pos distanceSqr _x, _x]};
	_playerList sort true;
	private _player = (_playerList select 0) param [1, objNull];
	{
		if ((_x distance2D _player) > 500) then {
			deleteVehicle _x;
		};
		if !(isNil "_x") then {
			if !(alive _x) then {_managedememies = _managedememies - [_x]};
		};
	} forEach _managedememies;

	{deleteMarker _x} forEach _civimarkers;
	{
		if (_x distance2D _target_pos > 500) then {
			deleteVehicle _x;
		} else {
			private _marker = createMarker [format["civ_marker_%1", [12] call fnc_genId], getPos _x];
			_marker setMarkerType "mil_dot";
			//_marker setMarkerSize [0.8, 0.8];
			if (_x getVariable["IS_FED", false] == true) then {
				_marker setMarkerText "Civilian [Assisted]";
				_marker setMarkerColor "ColorCIV";
			} else {
				_marker setMarkerText "Civilian [Unassisted]";
				_marker setMarkerColor "ColorGreen";
			};
			_civimarkers pushBack _marker;
		};
	} forEach _managedcivilians;

	// if closest player is within 3/4 distance to target pos than distance to target pos from start pos, spawn new enemy
	if ( ((_player distance2D _target_pos) > ((_trip_distance / 3) * 2)) || (_player distance2D _target_pos < 100) ) then {
		continue;
	};

	// spawn new ememies if applicable
	if (count _managedememies < 5) then {
		private _playerList = allPlayers apply {[_target_pos distanceSqr _x, _x]};
		_playerList sort true;
		private _player     = (_playerList select 0) param [1, objNull];
		private _forwardPos = [_player, selectRandom[125, 130, 133, 142, 150, 155, 160, 170]] call fnc_inFrontOf;
		private _group      = createGroup EAST;
		private _unitClass  = selectRandom (call fnc_getAllOpInfantry);
		private _unit = _group createUnit [_unitClass, _forwardPos, [], 0 , "NONE"];
		if ("female" in typeOf _unit) then {
			[_unit, true, 3] call fnc_setRandomIdentity;
		};
		[_group] call fnc_aggressive_ai;
		_managedememies pushBack _unit;
		[_unit] spawn {
			params["_unit"];
			private _start = getPos _unit;
			sleep 20;
			if (_start distance2D (getPos _unit) < 5) then {
				deleteVehicle _unit;
			};
		};
	};
};

{deleteMarker _x} forEach _civimarkers;

{deleteVehicle _x} forEach _managedememies;

{deleteVehicle _x} forEach _managedcivilians;

{deleteMarker _x} forEach _markermanager;

HUMANITARIAN_RUNNING = false;

["Intel", [format ["Humanitarian Mission at %1 has concluded.", _target_name]]] remoteExec ["BIS_fnc_showNotification"];