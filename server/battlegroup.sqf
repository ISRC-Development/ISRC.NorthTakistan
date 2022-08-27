if !(isServer) exitWith {};

if (count (profileNamespace getVariable ["CAPTURED_SECTORS", []]) == 0 ) exitWith {
	systemChat "[SERVER] No sectors captured yet, battlegroups are not forming yet.";
};

private _target_sector = call isrc_ufnc_getBattlegroupTargetPoint;
if (typeName _target_sector == "BOOL") exitWith {
	systemChat "[SERVER] No applicable battlegroup capture point found, battlegroups are not forming yet.";
};

private _target_name   = _target_sector select 0;
private _target_pos    = _target_sector select 1;
private _target_type   = _target_sector select 2;
private _target_uid    = _target_sector select 3;

private _deployment = call isrc_ufnc_getBattlegroupSpawnPoint;
if (typeName _deployment == "BOOL") exitWith {
	systemChat "[SERVER] No applicable battlegroup spawn point found, battlegroups are not forming yet.";
};

private _deployment_name   = _deployment select 0;
private _deployment_pos    = _deployment select 1;
private _deployment_type   = _deployment select 2;

["IntelRed", [format ["LANDSAT: A battlegroup has been spotted near %1.", _deployment_name]]] remoteExec ["BIS_fnc_showNotification"];

private _group_pos 		   = [_deployment_pos, 1, 850, 2, 0, 30, 0] call BIS_fnc_findSafePos;

systemChat format ["[SERVER] Battlegroup formation point found at %1", _group_pos];

[_target_name] spawn {
	sleep 2;
	["IntelRed", [format ["LANDSAT: A battlegroup is heading for %1.", _this select 0]]] remoteExec ["BIS_fnc_showNotification"];
};

private _bg_groups = [];

private _infantryManager = [
	// [_unit, _spawnPos], ...
];

/*
// Spawn Infantry
private _infantry_choices = ISRC_ENEMY_BATTLEGROUP get "infantry";
for "_i" from 1 to random (ISRC_ENEMY_BATTLEGROUP_WEIGHTS get "infantry") do {
	private _unit = _group createUnit [selectRandom _infantry_choices, _group_pos, [], 0, "NONE"];
	//_unit setVectorUp surfaceNormal (getposATL _unit);	
	[_unit] call fnc_setRandomIdentity;
	//[_unit] call fnc_freezefix;
	_infantryManager pushBack [_unit, getPos _unit];
};
*/

// Spawn Vehicles
for "_i" from 1 to random (ISRC_ENEMY_BATTLEGROUP_WEIGHTS get "vehicle") do {
	private _group = createGroup ENEMY_SIDE;
	private _vehclass = selectRandom (ISRC_ENEMY_BATTLEGROUP get "vehicle");
	private _veh 	  = _vehclass createVehicle ([_group_pos, 3, 250, 3, 0, 20, 0] call BIS_fnc_findSafePos);
	[_veh] call fnc_cleanVehicle;
    createVehicleCrew _veh;
	_bg_groups pushBack group driver _veh;
};

// Spawn Armor
for "_i" from 1 to random (ISRC_ENEMY_BATTLEGROUP_WEIGHTS get "armor") do {
	private _group = createGroup ENEMY_SIDE;
	private _vehclass = selectRandom (ISRC_ENEMY_BATTLEGROUP get "armor");
	private _veh 	  = _vehclass createVehicle ([_group_pos, 3, 250, 3, 0, 20, 0] call BIS_fnc_findSafePos);
	[_veh] call fnc_cleanVehicle;
	createVehicleCrew _veh;
	_bg_groups pushBack group driver _veh;
};

// Transport Vehicles
for "_i" from 0 to (selectRandom [1, 2, 3]) do {
	private _transport_veh    = ISRC_transport_truck createVehicle ([_group_pos, 3, 250, 3, 0, 20, 0] call BIS_fnc_findSafePos);
	private _group            = createGroup ENEMY_SIDE;
	for "_i" from 0 to 12 do {
		private _u = _group createUnit [selectRandom ISRC_transport_troops, [_group_pos, 3, 250, 3, 0, 20, 0] call BIS_fnc_findSafePos, [], 100, "NONE"];
		_u moveInAny _transport_veh;
		//[_u] call fnc_setRandomIdentity;
	};	
	_group setVariable ["is_transport", true];
	_bg_groups pushBack _group;
};

[_group_pos] spawn {
	params["_pos"];
	private _marker = createMarker [format["bg_instance_marker_%1", [12] call fnc_genId], _pos];
	_marker setMarkerType "loc_Attack";
	_marker setMarkerColor "ColorRed";
	_marker setMarkerSize [2, 2];
	sleep 60;
	deleteMarker _marker;
};

private _mid      = "marker_" + ([12] call fnc_genId);
private _waypoint = [];

//while {!((waypoints _group) isEqualTo [])} do {deleteWaypoint ((waypoints _group) select 0);};
//{_x doFollow leader _group} forEach _bg_units;

{
	_x setBehaviour "CARELESS";	
	private _way1 = _x addWaypoint [_target_pos, 0];
	_way1 setWaypointType "MOVE";
	_way1 setWaypointBehaviour "CARELESS";
	_way1 setWaypointCombatMode "yellow";
	_way1 setWaypointDescription "BG Move";
	_way1 setWaypointSpeed "FULL";
	_way1 setWaypointCompletionRadius 10;
	/*
		if (_x getVariable ["is_transport", false]) then {
			// Garrison the transported troops on arrival
			_way1 setWaypointScript "CBA_fnc_taskDefend [group _this#0]";	
		};
	*/
} forEach _bg_groups;

private _bg_units = [];
{
	_bg_units = _bg_units + (units _x);
} forEach _bg_groups;

{
	_x doMove _target_pos;
	sleep 1;
} forEach (_bg_units);

// TEST
{
	deleteGroup _x;
} forEach _bg_groups;

// while group is outside the recap range and alive.
while { {alive _x} count _bg_units > 0 } do 
{
	private _inarea = [];
	{
		if ((_x distance2D _target_pos) <= SECTOR_RECAP_RANGE) exitWith {
			_inarea pushBack _x;
		};
	} forEach (_bg_units);
	if (count _inarea > 0) exitWith {
		["IntelRed", [format ["A battlegroup has reached %1!", _target_name]]] remoteExec ["BIS_fnc_showNotification"];
	};
	sleep 5;
};

[_target_pos, _bg_groups] spawn {
	params["_target_pos", "_bg_groups"];
	sleep SECTOR_STRAGGLER_CUTOFF;
	{
		// Checks for stragglers and deletes them
		if (leader _x distance2D _target_pos > SECTOR_RECAP_SIZE) then {
			if !(isNull objectParent leader _x) then {
				deleteVehicle vehicle leader _x;
			};
			deleteGroup _x;
		};
	} forEach (_bg_groups);
};

// Either all are dead or they made it to the target sector.
if ({alive _x} count _bg_units > 0) then 
{
	{
		[_x] call fnc_aggressive_ai;
	} forEach _bg_groups;

	//[_group, _target_pos, SECTOR_RECAP_SIZE / 2] call BIS_fnc_taskPatrol;
	
	private _time = SECTOR_RECAP_TIME;
	private _bguidmarker = format ["bguid_%1", [12] call fnc_genId];

	while {({alive _x} count _bg_units > 0) && (_time != 0)} do 
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

		_time = _time - 1;

		if (count _enemies_in_area > count _friends_in_area) then {
			_marker setMarkerColor "ColorRed";
		} else {
			_marker setMarkerColor "ColorGreen";
		};

		_marker setMarkerText format["%1", [((_time)/60)-.01,"HH:MM"] call BIS_fnc_timetostring];
		sleep 1;
	};
	deleteMarker _bguidmarker;
	// One of three possibilities:
	// 1. All AI are dead. (defended)
	// 2. AI made it to the target sector then stayed in it for the target cap time. (captured)
	// 3. AI made it to the target sector but left before capturing. (defended)
	if ({alive _x} count _bg_units > 0) then 
	{
		if (_time == 0) then 
		{
			// CAPTURED BY OPFOR
			["IntelRed", [format ["%1 was lost to a battlegroup.", _target_name]]] remoteExec ["BIS_fnc_showNotification"];

			// Reestablish the sector
			profileNamespace setVariable ["CAPTURED_SECTORS", profileNamespace getVariable ["CAPTURED_SECTORS", []] - [_target_name]];
			saveprofilenamespace;

			RECAPTURED_SECTORS pushBack _target_name;

			deleteMarker format["marker_%1", _target_uid];

			[[
				_target_name,
				_target_pos,
				_target_type,
				_target_uid
			]] call fnc_establishSector;

		} else {
			// DEFENDED BY BLUFOR	
			["IntelGreen", [format ["%1 is no longer under attack.", _target_name]]] remoteExec ["BIS_fnc_showNotification"];
		};

		{
			if !(isNull objectParent _x) then {
				deleteVehicle (objectParent _x);
			};
			deleteVehicle _x;
		} forEach (_bg_units);

	} else {
		// DEFENDED BY BLUFOR
		["IntelGreen", [format ["%1 is no longer under attack.", _target_name]]] remoteExec ["BIS_fnc_showNotification"];		
	};

} else {
	// DEFENDED BY BLUFOR
	["IntelGreen", [format ["%1 is no longer under attack.", _target_name]]] remoteExec ["BIS_fnc_showNotification"];
};

deleteMarker _mid;
{deleteGroup _x} forEach _bg_groups;






