if !(isServer) exitWith {};

if (count (profileNamespace getVariable ["CAPTURED_SECTORS", []]) == 0 ) exitWith {
	systemChat "[SERVER] No sectors captured yet, battlegroups are not forming yet.";
};

private _rnd_sector = selectRandom (profileNamespace getVariable ["CAPTURED_SECTORS", []]);

private _target_sector = [_rnd_sector] call fnc_getLocationByName;

private _target_name   = _target_sector select 0;
private _target_pos    = _target_sector select 1;
private _target_type   = _target_sector select 2;

private _deployment = false;
while {typeName _deployment == "BOOL"} do {
	private _location = selectRandom (call fnc_getAllLocations);
	private _name     = _location select 0;
	if !(_name in (profileNamespace getVariable ["CAPTURED_SECTORS", []]) && (_location select 2) != "NameMarine") then {
		_deployment = _location;
	};
};

if (isNil "_deployment") exitWith {
	systemChat "[SERVER] No deployment location found.";
};

private _deployment_name   = _deployment select 0;
private _deployment_pos    = _deployment select 1;
private _deployment_type   = _deployment select 2;

private _group_pos 		   = [_deployment_pos, 1, 850, 2, 0, 35] call BIS_fnc_findSafePos;

["Intel", [format ["A battlegroup is heading for %1.", _target_name]]] remoteExec ["BIS_fnc_showNotification"];

// Get the location info for the sector
private _group = createGroup ENEMY_SIDE;

fn_safeBGPos = {
	params["_group_pos"];
	[_group_pos, 1, 750, 1, 0, 30, 0] call BIS_fnc_findSafePos
};

fn_crewed_bg_vic = {
	params["_type", "_pos", "_group", ["_amount", 3]];
	private _veh = createVehicle [_type, _pos, [], 150, "NONE"];
	[_veh] call fnc_cleanVehicle;
	//_veh setVectorUp surfaceNormal (getposATL _veh);	
	clearItemCargoGlobal _veh;
	for "_i" from 0 to 3 do {
		private _u = _group createUnit [selectRandom (( ISRC_ENEMY_INFANTRY select 2) select 1), getPos _veh, [], 100, "NONE"];
		_u moveInAny _veh;
		[_u] call fnc_setRandomIdentity;
	};
	_veh
};

private _infantryManager = [
	// [_unit, _spawnPos], ...
];

// Spawn Infantry
private _infantry_choices = ISRC_ENEMY_BATTLEGROUP get "infantry";
for "_i" from 1 to random (ISRC_ENEMY_BATTLEGROUP_WEIGHTS get "infantry") do {
	private _unit = _group createUnit [selectRandom _infantry_choices, _group_pos, [], 0, "NONE"];
	//_unit setVectorUp surfaceNormal (getposATL _unit);	
	[_unit] call fnc_setRandomIdentity;
	[_unit] call fnc_freezefix;
	_infantryManager pushBack [_unit, getPos _unit];
};

// Spawn Vehicles
for "_i" from 1 to random (ISRC_ENEMY_BATTLEGROUP_WEIGHTS get "vehicle") do {
	private _vehclass = selectRandom (ISRC_ENEMY_BATTLEGROUP get "vehicle");
	private _veh 	  = _vehclass createVehicle _group_pos;
	[_veh] call fnc_cleanVehicle;
	for "_i" from 0 to 3 do {
		private _u = _group createUnit [selectRandom (( ISRC_ENEMY_INFANTRY select 2) select 1), _group_pos, [], 100, "NONE"];
		_u moveInAny _veh;
		[_u] call fnc_setRandomIdentity;
	};	
};

// Spawn Armor
for "_i" from 1 to random (ISRC_ENEMY_BATTLEGROUP_WEIGHTS get "armor") do {
	private _vehclass = selectRandom (ISRC_ENEMY_BATTLEGROUP get "armor");
	private _veh 	  = _vehclass createVehicle _group_pos;
	[_veh] call fnc_cleanVehicle;
	for "_i" from 0 to 3 do {
		private _u = _group createUnit [selectRandom (( ISRC_ENEMY_INFANTRY select 2) select 1), _group_pos, [], 100, "NONE"];
		_u moveInAny _veh;
		[_u] call fnc_setRandomIdentity;
	};	 
};

private _transport_veh    = ISRC_transport_truck createVehicle _group_pos;

for "_i" from 0 to (selectRandom [1, 2, 3]) do {
	for "_i" from 0 to 12 do {
		private _u = _group createUnit [selectRandom ISRC_transport_troops, _group_pos, [], 100, "NONE"];
		_u moveInAny _transport_veh;
		[_u] call fnc_setRandomIdentity;
	};	
};

private _freeze_manager = [];

{
	_freeze_manager pushBack [_x, getPos _x];
} forEach units _group;

[_freeze_manager] spawn {
	params["_mngr"];
	sleep 240;
	{
		private _unit = _x select 0;
		private _pos  = _x select 1;
		if ((_pos distance2D (getPos _unit)) < 5) then {
			deleteVehicle _unit;
		};
	} forEach _mngr;
};

[_group_pos] spawn {
	params["_pos"];
	private _marker = createMarker [format["bg_instance_marker_%1", [12] call fnc_genId], _pos];
	_marker setMarkerType "loc_Attack";
	_marker setMarkerColor "ColorRed";
	_marker setMarkerSize [3, 3];
	sleep 60;
	deleteMarker _marker;
};

private _mid      = "marker_" + ([12] call fnc_genId);
private _waypoint = [];

//while {!((waypoints _group) isEqualTo [])} do {deleteWaypoint ((waypoints _group) select 0);};
{_x doFollow leader _group} forEach units _group;

_startpos = getPos (leader _group);
_group setBehaviour "CARELESS";

{
	_x doMove _target_pos;
	sleep 1;
} forEach (units _group);

private _way1 = _group addWaypoint [_target_pos, 0];
_way1 setWaypointType "MOVE";
_way1 setWaypointBehaviour "CARELESS";
_way1 setWaypointCombatMode "yellow";
_way1 setWaypointDescription "BG Move";
_way1 setWaypointSpeed "FULL";
_way1 setWaypointCompletionRadius 10;

// while group is outside the recap range and alive.
while { {alive _x} count units _group > 0 } do 
{
	private _inarea = [];
	{
		if ((_x distance2D _target_pos) <= SECTOR_RECAP_RANGE) exitWith {
			_inarea pushBack _x;
		};
	} forEach (units _group);
	if (count _inarea > 0) exitWith {
		["IntelRed", [format ["A battlegroup has reached %1!", _target_name]]] remoteExec ["BIS_fnc_showNotification"];
	};
	sleep 5;
};

[_target_pos, _group] spawn {
	params["_target_pos", "_group"];
	sleep SECTOR_STRAGGLER_CUTOFF;
	{
		// Checks for stragglers and deletes them
		if (_x distance2D _target_pos > SECTOR_RECAP_SIZE) then {
			deleteVehicle _x;
		};
	} forEach (units _group);
};

// Either all are dead or they made it to the target sector.
if ({alive _x} count units _group > 0) then 
{
	[_group] call fnc_aggressive_ai;

	[_group, _target_pos, SECTOR_RECAP_SIZE / 2] call BIS_fnc_taskPatrol;
	
	private _time = SECTOR_RECAP_TIME;
	private _bguidmarker = format ["bguid_%1", [12] call fnc_genId];

	while {({alive _x} count units _group > 0) && (_time != 0)} do 
	{
		deleteMarker _bguidmarker;
		_marker = createMarker [_bguidmarker, _target_pos];
		_marker setMarkerType "Select";
		_marker setMarkerSize [1.5, 1.5];
	
		private _friends_in_area = [];
		private _enemies_in_area = [];
		{
			if (side _x == independent) then {
				if (RESISTANCE_IS_FRIENDLY) then {
					_friends_in_area pushBack _x;
				} else {
					_enemies_in_area pushBack _x;
				};	
			};
			if (side _x == east) then {
				_enemies_in_area pushBack _x;
			};
			if (side _x == west) then {
				_friends_in_area pushBack _x;
			};
		} forEach (nearestObjects [_target_pos, [], SECTOR_RECAP_SIZE]);

		if (count _enemies_in_area > count _friends_in_area) then {
			_time = _time - 1;
			_marker setMarkerColor "ColorRed";
		} else {
			_marker setMarkerColor "ColorYellow";
		};

		_marker setMarkerText format["%1", [((_time)/60)-.01,"HH:MM"] call BIS_fnc_timetostring];
		sleep 1;
	};
	deleteMarker _bguidmarker;
	// One of three possibilities:
	// 1. All AI are dead. (defended)
	// 2. AI made it to the target sector then stayed in it for the target cap time. (captured)
	// 3. AI made it to the target sector but left before capturing. (defended)
	if ({alive _x} count units _group > 0) then 
	{
		if (_time == 0) then 
		{
			// CAPTURED BY OPFOR
			["IntelRed", [format ["%1 was lost to a battlegroup.", _target_name]]] remoteExec ["BIS_fnc_showNotification"];
			// Reestablish the sector
			private _captured_sectors = profileNamespace getVariable ["CAPTURED_SECTORS", []];
			profileNamespace setVariable ["CAPTURED_SECTORS", _captured_sectors - [_target_name]];
			[_target_sector] call fnc_establishSector;
		} else {
			// DEFENDED BY BLUFOR	
			["IntelGreen", [format ["%1 is no longer under attack.", _target_name]]] remoteExec ["BIS_fnc_showNotification"];
		};

		{
			if !(isNull objectParent _x) then {
				deleteVehicle (objectParent _x);
			};
			deleteVehicle _x;
		} forEach (units _group);

	} else {
		// DEFENDED BY BLUFOR
		["IntelGreen", [format ["%1 is no longer under attack.", _target_name]]] remoteExec ["BIS_fnc_showNotification"];		
	};

} else {
	// DEFENDED BY BLUFOR
	["IntelGreen", [format ["%1 is no longer under attack.", _target_name]]] remoteExec ["BIS_fnc_showNotification"];
};

deleteMarker _mid;
deleteGroup _group;






