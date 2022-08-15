/*
	Description:
		TURNKEY ACTIVE RADAR JAMMING SYSTEM FOR ANY PLATFORM.

	Issues:	
		*DOSN'T WORK AGAINST PLAYER-CONTROLLED VEHICLES!*

	USAGE:
		[player] call ISRCEWS_fnc_init; // Execute clientside and only ONCE!

		// optional: 
*/ 

// CONFIGURATION: 
//     1) preprocessFileLineNumbers "{this file}" to initplayerlocal.sqf
//     2) Run `[player] call ISRCEWS_fnc_init` in onPlayerRespawn.sqf
//     3) Optional: preprocessFileLineNumbers "client\experiments\electronic_warfare\server.sqf" to "initServer.sqf"

// Non-configurable variables
ISRCEWS_CURRENT_THREATS   = [];
ISRCEWS_CANCEL            = true;
ISRCEWS_SYSTEM_HEAT       = 0;
ISRCEWS_SYSTEM__READY     = false;
ISRCEWS_CAMERA_LOCAL      = false; // false unless active camera object is found
ISRCEWS_CAMERA_ZOOM       = 0;
ISRCEWS_CAMERA_TARGET     = getPos player;
ISRCEWS_MENU_OPEN 		  = false; // false unless menu is open	
ISRCEWS_CAM_MODES         = [
	[0, "NONE"],
	[1, "NVSS"],
	[2, "BHOT"],
	[7, "WHOT"],
	[8, "GHOT"]
];

call compileFinal preprocessFileLineNumbers "client\experiments\electronic_warfare\config.sqf";

call compileFinal preprocessFileLineNumbers "client\experiments\electronic_warfare\utils.sqf";

/// PUBLIC FUNCTIONS ///
ISRCEWS_fnc_init = {
	// Event handlers
	player addEventHandler ["SeatSwitchedMan", ISRCEWS_eh];
	player addEventHandler ["GetInMan", ISRCEWS_eh];
	player addEventHandler ["GetOutMan", {
		ISRCEWS_CANCEL = true;
		call ISRCEWS_fnc_destroyCamera;
	}];
	call compileFinal preprocessFileLineNumbers "client\experiments\electronic_warfare\aceActions.sqf"; // Load ACE action
	// Init applicable vehicles
	{
		[_x, "init",
		{ 
			private _vehicle = (_this select 0);
			{
				_vehicle addWeaponTurret ["CMFlareLauncher", _x];
				_vehicle addMagazineTurret ["300Rnd_CMFlare_Chaff_Magazine", _x, ISRCEWS_STARTING_CHAFF_AMOUNT];
			} forEach (allTurrets [_vehicle, true]);
			_vehicle setVariable ["ace_rearm_scriptedLoadout", true, true];
		},
		true,
		[],
		true
		] call CBA_fnc_addClassEventHandler;

		[_x, "Deleted",
		{ 
			private _vehicle = (_this select 0);
			{
				detach _x;
				deleteVehicle _x;
			} forEach attachedObjects _vehicle;
		},
		true,
		[],
		true
		] call CBA_fnc_addClassEventHandler;		
		
	} forEach (ISRCEWS_ALLOWED_PLATFORMS);
};

/// PRIVATE FUNCTIONS ///
ISRCEWS_fnc_pop_chaff = {
	params[["_count", 6], ["_interval", 1]];
	[_count, _interval] spawn {
		params["_count", "_interval"];
		for "_i" from 0 to _count do {
			if (call fnc_cmCount != 0) then {
				private _role = assignedVehicleRole player;
				private _turret_path = [-1]; // driver (pilot)
				if (_role select 0 == "turret") then { // Turret
					_turret_path = _role select 1;
				};
				//vehicle player addMagazineTurret ["300Rnd_CMFlare_Chaff_Magazine", _turret_path];
				player forceWeaponFire ["CMFlareLauncher", "Single"];
			} else {
				["[EWS->Countermeasures] Failed: Winchester"] call ISRCEWS_fnc_crewMessage;
			};
			sleep _interval;
		};
	};
};

ISRCEWS_eh = {
	if !(typeOf vehicle player in ISRCEWS_ALLOWED_PLATFORMS) exitWith {};
	call ISRCEWS_fnc_destroyCamera
	//call ISRCEWS_fnc_mainloop;
};

ISRCEWS_assessTarget = {
	// Assess target, jam if radar jamming possible ($_autoJammer).
	params["_vehicle", ["_autoJammer", false]];
	
	private _isThreat = createhashmapfromarray[
		["threat", false], 
		["type", "Unknown"],
		["radar", false],
		["aacapabilities", []],
		["jammed", false],
		["jamtime", 0]
	];
	
	if ( !(side _vehicle isEqualTo side player) && !(side _vehicle isEqualTo civilian) ) then {
		_isThreat set ["threat", true];
	};
	
	//_isThreat set ["type", [ configFile >> "CfgVehicles" >> typeOf _vehicle, true ] call BIS_fnc_returnParents select 2];
	
	_isThreat set ["radar", isVehicleRadarOn _vehicle];

	if (_isThreat get "threat" && _isThreat get "radar" && _autoJammer) then 
	{
		[_vehicle, _isThreat] spawn {

			private _vehicle = _this select 0;
			private _threat  = _this select 1;

			private _marker = createMarker [format["marker_%1", [16] call fnc_genId], getPos _vehicle];
			_marker setMarkerColor "ColorRed";
			_marker setMarkerType "Minefield";
		
			_marker setMarkerText format["[%1] - %2 - EWS Active", [dayTime] call BIS_fnc_timeToString, _threat get "type"];

			// JAMMING
			{
				[_vehicle, [_x, false]] remoteExec ["enableVehicleSensor", _vehicle];
			} forEach [
				"ActiveRadarSensorComponent",
				"PassiveRadarSensorComponent"
			];
			[_vehicle, 2] remoteExec ["setVehicleRadar", _vehicle];
			[_vehicle, false] remoteExec ["setVehicleReportRemoteTargets", _vehicle];

			sleep ISRCEWS_JAM_TIME;

			// UN...JAMMING
			{
				[_vehicle, [_x, true]] remoteExec ["enableVehicleSensor", _vehicle];
			} forEach [
				"ActiveRadarSensorComponent",
				"PassiveRadarSensorComponent"
			];			
			[_vehicle, 0] remoteExec ["setVehicleRadar", _vehicle];
			[_vehicle, true] remoteExec ["setVehicleReportRemoteTargets", _vehicle];

			deleteMarker _marker;
		};
	};
	_isThreat
};

ISRCEWS_fnc_markerFlare = {
	params[["_flare", "Green"]]; // Green, Red, White, Yellow, CIR
	private _player_pos = getPos vehicle player;
	private _flare      = format["F_40mm_%1", _flare] createVehicle [_player_pos select 0, _player_pos select 1, _player_pos select 2 - 0.5];
	_flare setVelocity [20, 0, 0];
};

ISRCEWS_obstructCrewVisionAndIRAndLaser = {
	[_this] spawn {
		params[["_pos", getPos player], ["_enemy_side", EAST], ["_range", 1000], ["_time", 10]];
		ISRCEWS_CACHE_OBSTRUCTED_ASSETS = [];
		{
			if (count crew _x > 0 && side (crew _x select 0) isEqualTo _enemy_side) then {
				private _vehicle = _x;
				{
					[_vehicle, [_x, false]] remoteExec ["enableVehicleSensor", _vehicle];
				} forEach [
					"VisualSensorComponent",
					"IRSensorComponent",
					"LaserSensorComponent",
					"NVSensorComponent"
				];
				ISRCEWS_CACHE_OBSTRUCTED_ASSETS pushBack _x;
				systemChat format["Obstructing %1", _x];
			};
		} forEach (nearestObjects [getPos player, ["Tank", "Truck", "Air", "Turret", "Radar", "Car", "Bike"], _range]);				
		sleep _time;
		{
			private _vehicle = _x;
			{
				[_vehicle, [_x, true]] remoteExec ["enableVehicleSensor", _vehicle];
			} forEach [
				"VisualSensorComponent",
				"IRSensorComponent",
				"LaserSensorComponent",
				"NVSensorComponent"
			];
			systemChat format["De-Obstructing %1", _x];	
		} forEach ISRCEWS_CACHE_OBSTRUCTED_ASSETS;
		ISRCEWS_CACHE_OBSTRUCTED_ASSETS = [];
	};
};

/*
ISRCEWS_fnc_mainloop = {  /// Confusing but this does the initial startup on vehicles when getting in as well as the refresh on player seat change.
	//params["_vehicle", "_unit"];
	ISRCEWS_CURRENT_THREATS = [];

	ISRCEWS_CANCEL 		 	= true;  // Close any existing loops...
	ISRCEWS_SYSTEM__READY 	= true; // ...and reset the ISRCEWS_SYSTEM_HEAT       = 0;ISRCEWS_SYSTEM_HEAT       = 0;
	//ISRCEWS_SYSTEM_HEAT     = 0;    // ...and reset the system heat.

	// Temperature Monitor
	[] spawn {
		sleep (1); 						 // ...and wait for them to close.	
		ISRCEWS_CANCEL 		 	= false; 
		ISRCEWS_SYSTEM__READY   = true;
		while {!ISRCEWS_CANCEL} do {
			if (ISRCEWS_SYSTEM_HEAT >= ISRCEWS_OVERHEAT_THRESHOLD) then {
				if (ISRCEWS_SYSTEM__READY) then {
					[vehicle player, "[EWS] System Overheated, cooling down!"] call ISRCEWS_fnc_crewMessage;
				};
				ISRCEWS_SYSTEM__READY = false;
			} else {
				if (!ISRCEWS_SYSTEM__READY) then {
					[vehicle player, "[EWS] System Ready!"] call ISRCEWS_fnc_crewMessage;
				};
				ISRCEWS_SYSTEM__READY = true;
			};
			sleep 0.5;	
			ISRCEWS_SYSTEM_HEAT = ISRCEWS_SYSTEM_HEAT - ISRCEWS_OVERHEAT_COOLING_COEF;
			if (ISRCEWS_SYSTEM_HEAT < 0) then {ISRCEWS_SYSTEM_HEAT = 0};
		};

		// Player has most likely left the vehicle or changed seats.
		[ format["[EWS] Temparature System Exiting..."] ] call ISRCEWS_fnc_crewMessage;
		//systemChat "[EWS] Temparature System Exiting...";
	};
};
*/

ISRCEWS_fnc_crewMessage = {
	params["_message"];
	{[vehicle player, format["%1", _message]] remoteExec ["vehicleChat", _x]} forEach crew (vehicle player);
};

ISRCEWS_fnc_startJammer = {
	ISRCEWS_CURRENT_THREATS = [];
	ISRCEWS_SYSTEM__READY   = false;
	//if (ISRCEWS_SYSTEM_HEAT >= ISRCEWS_OVERHEAT_THRESHOLD) then {
		{
			private _threat = [_x, true] call ISRCEWS_assessTarget;
			//systemChat format ["ISRCEWS Threat: %1", _threat];
			if (_threat get "threat" && !(_x in ISRCEWS_CURRENT_THREATS)) then {
				[format["[EWS] System Is Jamming %1 At Gridpos %2!", count ISRCEWS_CURRENT_THREATS, mapGridPosition _x]] call ISRCEWS_fnc_crewMessage;
				ISRCEWS_CURRENT_THREATS pushBack _x;
				ISRCEWS_SYSTEM_HEAT = ISRCEWS_SYSTEM_HEAT + ISRCEWS_OVERHEAT_HEATING_COEF;
			};
		} forEach (nearestObjects [getPos player, ["Tank", "Truck", "Air", "Turret", "Radar", "Car", "Bike"], ISRCEWS_ENGAGEMENT_RADIUS]);
		if (count ISRCEWS_CURRENT_THREATS == 0) then {
			["[EWS] System Found 0 Threats!"] call ISRCEWS_fnc_crewMessage;
			ISRCEWS_SYSTEM__READY = true;
			ISRCEWS_SYSTEM_HEAT   = 0;
		} else {
			[] spawn {
				private _markers = [];
				{
					private _marker = [
						["start", getPos player],
						["end", getPos _x],
						["color", "ColorRed"],
						["size", 12]
					] call fnc_drawLine;
					_markers pushBack _marker;
				} forEach ISRCEWS_CURRENT_THREATS;
				sleep (ISRCEWS_JAM_TIME);
				ISRCEWS_SYSTEM__READY = true;
				ISRCEWS_SYSTEM_HEAT   = 0;
				if !(isNull objectParent player) then {
					["[EWS] Jamming Complete!"] call ISRCEWS_fnc_crewMessage;
				};
				{deleteMarker _x} forEach _markers;
			};
		};
	//} else {
	//	["[EWS] System Overheat!"] call ISRCEWS_fnc_crewMessage;
	//};
	ISRCEWS_SYSTEM__READY = true; // temporary fix for the addaction not being available. Always true for now.
	
	//[format["[EWS] System Temperature (Incremental): %1", ISRCEWS_SYSTEM_HEAT]] call ISRCEWS_fnc_crewMessage;
	//[format["[EWS] System Found And Is Jamming %1 Threats For %2 seconds!", count ISRCEWS_CURRENT_THREATS, ISRCEWS_JAM_TIME]] call ISRCEWS_fnc_crewMessage;
};

ISRCEWS_RSC_eh_onDestroy = {
	params ["_ctrl"]; 
	ISRCEWS_MENU_OPEN = false;
	ISRCEWS_CAMERA_LOCAL = false;
 	_display = ctrlParent _ctrl; 
 	_display closeDisplay 1;
};



