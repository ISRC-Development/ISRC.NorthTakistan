isrc_ufnc_getNearestEnemyToUnit = {
	params["_unit"];
	private _nearestEnemyToUnit = false;
	private _enemyPlayers       = allUnits select {side _x in ([side _unit] call BIS_fnc_enemySides)} apply {[_x distance _unit,_x]};
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
