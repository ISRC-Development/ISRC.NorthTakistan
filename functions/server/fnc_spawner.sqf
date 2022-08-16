// Global ->
// [...] call spawner;

if (isServer && !hasInterface && HCL_ENABLED) exitWith { // if dedicated server, sent to the headless client instead if hc is enabled.
	private _didExec = [_this select 0] remoteExec ["fnc_callSpawnerHC", hc1];
};

_trigger               = _this select 0; // Trigger    

private _location_meta = _trigger getVariable ["location_meta", false];

private _poiName 	   = _location_meta select 0; // POI Name              - String - name of the POI to show
private _pos           = _location_meta select 1; // POI Position          - Array  - [x,y,z] 
private _locationType  = _location_meta select 2; // POI Type              - String - type of the POI
private _locationUID   = _location_meta select 3; // POI UID               - String - unique ID of the POI
private _locationMarker= _location_meta select 4; // POI Marker            - String - marker of the POI

// Radius's
private _infantryRadius= _location_meta select 5; // Infantry Spawn Radius 
private _vehicleRadius = _location_meta select 6; // Vehicle Spawn Radius
private _airRadius     = _location_meta select 7; // Air Spawn Radius
private _armorRadius   = _location_meta select 8; // Armor Spawn Radius

// Get Amounts to spawn
private _infantryAmount= selectRandom (_location_meta select 9); // Infantry Amount  
private _vehicleAmount = selectRandom (_location_meta select 10); // Vehicle Amount
private _airAmount     = selectRandom (_location_meta select 11); // Air Amount
private _armorAmount   = selectRandom (_location_meta select 12); // Armor Amount

private _marker = "marker_" + _locationUID; // Get Marker name

// Trigger Stuff
_triggerpos = getPos _trigger;

// Activate Sector from serverside
[_trigger] remoteExec ["fnc_activate_sector", 2];

_iuid      = "indicator_" + _locationUID; // Get Marker name
_indicator = createMarker[_iuid, _triggerpos];
_indicator setMarkerType "mil_objective"; 
_indicator setMarkerColor "ColorRed";

// Delete previous civilian population
/*
{
	if (side group _x == civilian) then {
		if (_x != vehicle _x) then {
			deleteVehicle vehicle _x;
		};
		deleteVehicle _x;
	};
} forEach allUnits;
*/

if (_locationType != "NameMarine") then {

	[_triggerpos, _infantryRadius] spawn {
		for "_i" from 0 to MAX_CIV_POP_PEDS do {
			private _unitClass = selectRandom ISRC_civilians;
			private _action    = "spawn_civilian_ped";
			if (selectRandom[false, false, false, false, false, true]) then {
				_action = "spawn_ssb_ped";
			};
			[_action, [
				_unitClass,
				[[_this], []] call BIS_fnc_randomPos
			]] call fnc_new_HC_job;	
		};	
	};

	[_triggerpos, _infantryRadius] spawn {
		for "_i" from 0 to MAX_CIV_POP_TRAFFIC do {
			private _unitClass = selectRandom ISRC_civilians;
			private _vehClass  = selectRandom ISRC_civilian_vehicles;
			private _action    = "spawn_civilian_motorist";
			if (selectRandom[false, false, false, false, false, true]) then {
				_action = "spawn_ssb_motorist";	
			};
			[_action, [
				_unitClass,
				_vehClass,
				[[_this], []] call BIS_fnc_randomPos
			]] call fnc_new_HC_job;	
		};
	};

	[_triggerpos, _infantryAmount, _infantryRadius] spawn {
		params["_triggerpos", "_infantryAmount", "_infantryRadius"];
		for "_i" from 0 to _infantryAmount do {
			private _group        = createGroup ENEMY_SIDE;
			private _generalpos   = [[[_triggerpos, _infantryRadius]], []] call BIS_fnc_randomPos;
			private _randomGroup  = selectRandom ISRC_ENEMY_INFANTRY;
			private _FD_group_name  = _randomGroup select 0;
			private _FD_group_units = _randomGroup select 1;
			["spawn_group", [
				side _group,
				_FD_group_units,
				_generalpos,
				true,
				[_generalpos, _infantryRadius]
			]] call fnc_new_HC_job;
		};
	};

	[_triggerpos, _vehicleAmount, _vehicleRadius] spawn {
		params["_triggerpos", "_vehicleAmount", "_vehicleRadius"];
		for "_i" from 0 to _vehicleAmount do {
			["spawn_crewed_vehicle", [
				selectRandom ISRC_ENEMY_CAR,
				[_triggerpos, 1, _vehicleRadius, 5, 0, 15, 0, [], []] call BIS_fnc_findSafePos,
				true,
				[]
			]] call fnc_new_HC_job;
		};
	};

	[_triggerpos, _armorAmount, _armorRadius] spawn {
		params["_triggerpos", "_armorAmount", "_armorRadius"];
		for "_i" from 0 to _armorAmount do {
			["spawn_crewed_vehicle", [
				selectRandom ISRC_ENEMY_ARMOR,
				[_triggerpos, 1, _armorRadius, 5, 0, 15, 0, [], []] call BIS_fnc_findSafePos,
				true,
				[]
			]] call fnc_new_HC_job;	
		};
	};
} else {
	[_triggerpos, _vehicleAmount, _vehicleRadius] spawn {
		params["_triggerpos", "_vehicleAmount", "_vehicleRadius"];
		for "_i" from 0 to _vehicleAmount do {
			["spawn_crewed_vehicle", [
				selectRandom ISRC_ENEMY_MARINE,
				[_triggerpos, 1, _vehicleRadius, 5, 2, 15] call BIS_fnc_findSafePos,
				true,
				[_triggerpos, _vehicleRadius]
			]] call fnc_new_HC_job;	
		};
	};
};

// Get a new, enemy-held point to fly in from. (last point will be the point that is proced) 
private _air_deployment = false;
while {typeName _air_deployment == "BOOL"} do {
	private _ld = selectRandom (call fnc_getAllLocations);
	private _lName = _ld select 0;
	private _lType = _ld select 2;
	if !(_lName in (profileNamespace getVariable ["CAPTURED_SECTORS", []]) && _lType != "NameMarine") then {
		_air_deployment = _ld;
	};
};
private _air_deployment_name   = _air_deployment select 0;
private _air_deployment_pos    = _air_deployment select 1;
private _air_deployment_type   = _air_deployment select 2;
[_air_deployment_pos, _airAmount, _airRadius, _pos] spawn {
	params["_triggerpos", "_airAmount", "_airRadius", "_sector"];
	for "_i" from 0 to _airAmount do 
	{
		["spawn_crewed_vehicle", [
			selectRandom ISRC_ENEMY_AIR,
			[[[_triggerpos, _airRadius]], []] call BIS_fnc_randomPos,
			true,
			[_sector, _airRadius]
		]] call fnc_new_HC_job;	
	};
};

sleep 45;
private _units = (_triggerpos nearEntities [["Man", "Car", "Air", "Motorcycle", "Tank", "Turret", "Truck", "Ship", "Boat"], _airRadius * 1.5]) select { side _x == ENEMY_SIDE || (RESISTANCE_IS_FRIENDLY == false && side _x == resistance)};
// looks for men that are enemy and within 1.5x the airradius and are not in a vehicle and are in a group with unit count > 1
/////////////////// Sector Loop -> ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

private _capCoefficient = round((count _units) * SECTOR_CAPTURE_COEFFICIENT);
while { ({ alive _x } count _units > _capCoefficient) } do {
	/*
		{
			if (side _x == ENEMY_SIDE) then {
				private _thisgroup = _x;
				if ( count units _thisgroup < 2) then {
					deleteGroup _thisgroup;
				} else {
					if ( (leader _thisgroup) distance2D _pos > _airRadius * 2) then {
						{
							if !(isNull objectParent _x) then {
								deleteVehicle vehicle _x;
							};
							deleteVehicle _x
						} forEach units _thisgroup;
					};
				};
			};		
		} forEach allGroups;
	*/
	_units = (_triggerpos nearEntities [["Man", "Car", "Air", "Motorcycle", "Tank", "Turret", "Truck", "Ship", "Boat"], _airRadius * 1.5]) select { side _x == ENEMY_SIDE || (RESISTANCE_IS_FRIENDLY == false && side _x == resistance)}; // && isNull objectParent _x && count units group _x > 1
	sleep 15;
};

/*
// Cleanup remaining units
{
	if !(isNull objectParent _x) then {
		deleteVehicle vehicle _x;
	};
	deleteVehicle _x;
} forEach _units;
*/

// Deactivate Sector from serverside
[_poiName, _locationType, _triggerpos] remoteExec ["fnc_deactivate_sector", 2];

deleteMarker _indicator;
_marker setMarkerColor "ColorBlue";























