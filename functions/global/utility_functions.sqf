isrc_ufnc_getNearestEnemyToUnit = {
	// Todo: take into consideration the enemy status of resistance fighters.
	params["_unit_or_pos", ["_unit_side", EAST]];
	private _nearestEnemyToUnit = false;
	private _enemyPlayers       = allUnits select {side _x in ([_unit_side] call BIS_fnc_enemySides)} apply {[_x distance _unit_or_pos,_x]};
	if (count _enemyPlayers > 0) then {
		_enemyPlayers sort true;
		_nearestEnemyToUnit = (_enemyPlayers apply {_x#1})#0;
	};
	_nearestEnemyToUnit
};

isrc_ufnc_getNearestBuildingPos = {
	// [_unit_or_pos] call isrc_ufnc_getNearestBuildingPos -> _pos
	// Todo: take into consideration a map that has no buildings
	( (nearestBuilding (_this#0)) buildingPos -1)#0
};

isrc_ufnc_getEnemySector = {
    private _enemySector = false;
	private _locations = call fnc_GetAllLocations select {!(_x select 0 in (profileNamespace getVariable ["CAPTURED_SECTORS", []])) && !(_x select 0 in ALREADY_CAPTURED)};
    if (count _locations > 0) then {
        _enemySector = [selectRandom _locations select 0] call fnc_getLocationByName;
    };
    _enemySector
};

isrc_ufnc_getCapturedSector = {
    private _capturedSector  = false;
	private _capturedSectors = (profileNamespace getVariable ["CAPTURED_SECTORS", []]) + ALREADY_CAPTURED;
    if (count _capturedSectors > 0) then {
        _capturedSector = [selectRandom _capturedSectors] call fnc_getLocationByName;
    };
    _capturedSector
};

isrc_ufnc_getBattlegroupSpawnPoint = {
	private _spawnPoint = false;	
	private _enemySectors = call fnc_GetAllLocations select {!(_x select 0 in (profileNamespace getVariable ["CAPTURED_SECTORS", []])) && !(_x select 0 in ALREADY_CAPTURED)};
	if (count _enemySectors > 0) then {
		// Furthest enemy sector from the player spawn point.
		private _sorted = _enemySectors apply {[(_x select 1) distance RESPAWN_LOCATION, _x]};
		_spawnPoint = _sorted#(count _sorted-1)#1;
	};
	_spawnPoint
};

isrc_ufnc_getBattlegroupTargetPoint = {
	private _targetPoint = false;	
	private _capturedSectors = call fnc_GetAllLocations select {(_x select 0 in (profileNamespace getVariable ["CAPTURED_SECTORS", []])) || (_x select 0 in ALREADY_CAPTURED)};
	if (count _capturedSectors > 0) then {
		// Furthest captured sector from the player spawn point.
		private _sorted = _capturedSectors apply {[(_x select 1) distance RESPAWN_LOCATION, _x]};
		_targetPoint = _sorted#(count _sorted-1)#1;
	};
	_targetPoint
};
	