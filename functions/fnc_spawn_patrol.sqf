params["_pos", "_destination", "_lifetime_seconds"];

if ( count (allPlayers select {typeOf _x != "HeadlessClient_F"}) == 0 ) exitWith {
	diag_log "[ISRC Liberation] Not enough players: exiting fnc_spawn_patrol.sqf...";
	systemChat "[ISRC Liberation] Not enough players: exiting fnc_spawn_patrol.sqf...";
};

private _patrol       = selectRandom ISRC_ENEMY_PATROLS;
private _patrol_teams = [];
{
    private _team = _x;
    private _group = createGroup EAST;
    if (typeName (_team select 0) != "BOOL") then
    { 
	
	    // mechanized patrol
		private _vehicle = (_team select 0) createVehicle _pos;
		createVehicleCrew _vehicle;    
		(crew _vehicle) join _group;
		private _crew = _team select 1;
		{
			private _unit = _group createUnit [_x, _pos, [], 0, "NONE"]; // 
			_unit moveInAny _vehicle;
		} forEach _crew;
    
	} else {

		// foot patrol
		private _crew = _team select 1;
		for "_i" from 0 to (count _crew) do {
			0 = _group createUnit [_x, _pos, [], 0, "NONE"];
		};
		
    };
    _patrol_teams pushBack _group;
} forEach _patrol;

[_patrol_teams, _lifetime_seconds] spawn {
	params["_patrol_teams", "_lifetime_seconds"];
	{
		_x setSpeedMode "FULL";
		_x setCombatMode "RED";
		sleep 5;
		_x deleteGroupWhenEmpty true;
		private _waypoint = _x addWaypoint [[0, 0, 0], -1];
		_waypoint setWaypointPosition [[leader _x, side leader _x] call isrc_ufnc_getNearestEnemyToUnit, -1];
		_waypoint setWaypointType "SAD";
		//_waypoint setWaypointName "";
		//_waypoint setWaypointDescription "";
		//_waypoint setWaypointFormation "NO CHANGE";
		//_waypoint setWaypointBehaviour "UNCHANGED";
		//_waypoint setWaypointCombatMode "RED";
		//_waypoint setWaypointSpeed "UNCHANGED";
		//_waypoint setWaypointTimeout [0,0,0];
		_waypoint setWaypointCompletionRadius 0;
		_waypoint setWaypointStatements ["true",""];
		//_waypoint setWaypointScript "";

		//[_x, _destination, selectRandom [300, 500, 500, 800]] call BIS_fnc_taskPatrol;

	} forEach _patrol_teams;

	sleep _lifetime_seconds;
	{
		{
			if !(isNull objectParent _x) then {
				deleteVehicle vehicle _x;
			};
			deleteVehicle _x;
		} forEach (units _x);
	} forEach _patrol_teams;
};

["IntelRed", ["LANDSAT: Enemy is mobilizing for an attack on friendly forces!"]] remoteExec ["BIS_fnc_showNotification"];
