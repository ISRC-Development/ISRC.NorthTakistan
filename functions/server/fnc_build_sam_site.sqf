params["_position"];

// Get a safe pos
private _safe_pos = [_position, 3, 600, 15, 0, 15, 0] call BIS_fnc_findSafePos;

// clean up the area
{
	hideObjectGlobal _x;
} forEach nearestTerrainObjects [_safe_pos, [], 100];

{
	hideObjectGlobal _x;
} forEach nearestObjects [_safe_pos, [], 100];

// Create a SAM 
private _sam = "O_SAM_System_04_F" createVehicle _safe_pos;
[
	_sam,
	["JungleHex",1], 
	true
] call BIS_fnc_initVehicle;

_sam addMPEventHandler ["MPKilled ",{
	private _samCount = missionNamespace getVariable "SAM_COUNT";
	_samCount = _samCount - 1;
	missionNamespace setVariable ["SAM_COUNT", _samCount]
}];

createVehicleCrew _sam;
_sam setVariable ["IS_PROP", true];

// Create a radar to the side
private _radar = "rhs_prv13_turret_vpvo" createVehicle ([[15, 15, 0], _safe_pos] call BIS_fnc_vectorAdd);
createVehicleCrew _radar;
_radar setVariable ["IS_PROP", true];

private _camonet = "ShedBig" createVehicle ([[0, 10, 0], _safe_pos] call BIS_fnc_vectorAdd);
_camonet setVariable ["IS_PROP", true];

sleep 5;

_sam setDir getDir _radar;
_camonet setDir getDir _sam; 
_camonet setDir (getDir _camonet + 90);




