params["_position", ["_type", "RHS_BM21_VDV_01"]];

// Get a safe pos
private _safe_pos = [_position, 3, 600, 15, 0, 15, 0] call BIS_fnc_findSafePos;

// clean up the area
{
	hideObjectGlobal _x;
} forEach nearestTerrainObjects [_safe_pos, [], 50];

{
	hideObjectGlobal _x;
} forEach nearestObjects [_safe_pos, [], 50];

// Create a battery 
private _battery = _type createVehicle _safe_pos;

createVehicleCrew _battery;
_battery setVariable ["IS_PROP", true];
gunner _battery setVariable ["is_mortarman", true];
driver _battery setVariable ["is_mortarman", true];

private _camonet = "ShedBig" createVehicle ([[0, 10, 0], _safe_pos] call BIS_fnc_vectorAdd);
_camonet setVariable ["IS_PROP", true];

sleep 5;

_camonet setDir getDir _battery; 
_camonet setDir (getDir _camonet + 90);




