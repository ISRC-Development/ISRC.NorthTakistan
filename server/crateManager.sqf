// File: server\crateManager.sqf

// Author: Grom

// Description: 
/* 	- Completely Server-based Crate/Resupply system.
  	- See `config\weaponsAndCrates.sqf`!
*/

CRATE_MANAGER = createHashMapFromArray[
    [
        "HQ", 
        createHashMapFromArray [ ["types", ["general_resupply"]], ["amount", 4],  ["time_left", RESUPPLY_INTERVAL_SECONDS]]
    ],
    [
        "HQ_MEDICAL", 
        createHashMapFromArray [ ["types", ["medical_resupply"]], ["amount", 6],  ["time_left", RESUPPLY_INTERVAL_SECONDS]]
    ],
    [
        "KEEPER", 
        createHashMapFromArray [ ["types", ["general_resupply", "medical_resupply", "empty_resupply", "STATIC"]], ["amount", 10],  ["time_left", RESUPPLY_INTERVAL_SECONDS]]
    ],
    [
        "INFANTRY_1_1",
        createHashMapFromArray [ ["types", ["general_resupply", "medical_resupply"]], ["amount", 2],  ["time_left", RESUPPLY_INTERVAL_SECONDS]]
    ],
    [
        "INFANTRY_1_2",
        createHashMapFromArray [ ["types", ["general_resupply", "medical_resupply"]], ["amount", 2],  ["time_left", RESUPPLY_INTERVAL_SECONDS]]
    ],
    [
        "INFANTRY_1_3",
        createHashMapFromArray [ ["types", ["general_resupply", "medical_resupply"]], ["amount", 2],  ["time_left", RESUPPLY_INTERVAL_SECONDS]]
    ],
    [
        "INFANTRY_1_4",
        createHashMapFromArray [ ["types", ["general_resupply", "medical_resupply", "at_resupply", "STATIC"]], ["amount", 4],  ["time_left", RESUPPLY_INTERVAL_SECONDS]]
    ],
	[
		"PHANTOM",
		createHashMapFromArray [ ["types", ["general_resupply", "medical_resupply", "STATIC"]], ["amount", 3],  ["time_left", RESUPPLY_INTERVAL_SECONDS]]
	],
	[
		"IDF",
		createHashMapFromArray [ ["types", ["STATIC"]], ["amount", 2],  ["time_left", RESUPPLY_INTERVAL_SECONDS]]
	]
];

CRATE_GROUPS = ["HQ", "HQ_MEDICAL", "KEEPER", "INFANTRY_1_1", "INFANTRY_1_2", "INFANTRY_1_3", "INFANTRY_1_4", "PHANTOM", "IDF"];

[] spawn {
	while {true} do {
		{
			private _group_ledger = CRATE_MANAGER get _x;
			private _time_left    = _group_ledger get "time_left";
			private _amount       = _group_ledger get "amount";
			if (_time_left != 0) then {
				_group_ledger set ["time_left", _time_left - 1];
			} else {
				_group_ledger set ["amount", _amount + 1];
				_group_ledger set ["time_left", RESUPPLY_INTERVAL_SECONDS];
			};
			CRATE_MANAGER set [_x, _group_ledger];
			//systemChat format["%1: %2", _x, _group_ledger];
		} forEach CRATE_GROUPS;
		sleep 1;		
	};
};

fnc_useCrateTicket = {
	params["_crate_group"];
	private _group_ledger = CRATE_MANAGER get _crate_group;
	private _amount       = _group_ledger get "amount";
	_group_ledger set ["amount", _amount - 1];
	CRATE_MANAGER set [_crate_group, _group_ledger];
};

fnc_getCrateGroup = {
	params["_player"];
	private _role = roleDescription _player;
	private _crate_group = false;
	if ( "Legion 6" in _role || "Legion 7" in _role) then {
		_crate_group = "HQ";
	};
	if ( "Legion 8" in _role || "Banshee" in _role) then {
		_crate_group = "HQ_MEDICAL";
	};
	if ( "Legion 1-1" in _role) then {
		_crate_group = "INFANTRY_1_1";
	};
/*
	if ( "Legion 1-2" in _role) then {
		_crate_group = "INFANTRY_1_2";
	};
	if ( "Legion 1-3" in _role) then {
		_crate_group = "INFANTRY_1_3";
	};
*/
	if ( "Legion 1-2" in _role) then { // Notice: 1-4 has been removed, only 1-1/1-2 remain
		_crate_group = "INFANTRY_1_4";
	};
	if ( "Keeper" in _role) then {
		_crate_group = "KEEPER";
	};
	if ( "Phantom" in _role ) then {
		_crate_group = "PHANTOM";
	};
	if ( "Witchdoctor" in _role ) then {
		_crate_group = "IDF";
	};
	_crate_group
};

fnc_hasOneTicket = {
	params["_crate_group"];
	private _group_ledger = CRATE_MANAGER get _crate_group;
	private _amount       = _group_ledger get "amount";
	(_amount > 0)
};

fnc_getTicketsLeft = {
	params["_crate_group"];
	private _group_ledger = CRATE_MANAGER get _crate_group;
	private _amount       = _group_ledger get "amount";
	_amount
};

fnc_getTimeLeft = {
	params["_crate_group"];
	private _group_ledger = CRATE_MANAGER get _crate_group;
	private _time_left    = _group_ledger get "time_left";
	_time_left
};

fnc_pullCrateServer = {
	params["_player", "_crate_type", ["_static", false]];

	private _crate_group = [_player] call fnc_getCrateGroup;

	//systemChat format["[CRATE SYSTEM] %1: %2", _crate_group, _crate_type];

	if (typeName _crate_group == "BOOL") exitWith {
		["You are not allowed to access this logistics point from your current role."] remoteExec ["hint", _player];
	};

	if !([_crate_group] call fnc_hasOneTicket) exitWith {
		[format["You don't have any crates/weapons waiting. Time until next crate/weapon ready: %1", [[_crate_group] call fnc_getTimeLeft, "HH:MM:SS"] call BIS_fnc_secondsToString]] remoteExec ["hint", _player];
	};

	[_crate_group] call fnc_useCrateTicket;

	private "_crateOrWeapon";
	if !(_static) then {
		{

			if (_crate_type == (_x select 0)) then {

				private _cratename        = _x select 0; // ex: "at_resupply"
				private _crateobject      = _x select 1; // ex: "Box_NATO_Wps_F"
				private _crateweapons     = _x select 2; // ex: [["rhs_weap_m249_pip_S", 1]]
				private _cratemagazines   = _x select 3; // ex: [["rhs_200rnd_556x45_M_SAW", 1]]
				private _crateitems       = _x select 4; // ex: [["rhs_weap_m249_pip_S", 1]]				

				_crateOrWeapon = createVehicle [_crateobject, [player, 1, 5, 2, 0, 30, 0] call BIS_fnc_findSafePos, [], 0, "CAN_COLLIDE"];
				_crateOrWeapon allowDamage false;
				clearItemCargoGlobal     _crateOrWeapon;
				clearWeaponCargoGlobal   _crateOrWeapon;
				clearMagazineCargoGlobal _crateOrWeapon;
				clearBackpackCargoGlobal _crateOrWeapon;                
				{
					_crateOrWeapon addWeaponCargoGlobal _x;
				} forEach _crateweapons;
				{
					_crateOrWeapon addMagazineCargoGlobal _x;
				} forEach _cratemagazines;
				{
					_crateOrWeapon addItemCargoGlobal _x;
				} forEach _crateitems;
			};
		} forEach ISRC_supply_crates;
		_crateOrWeapon setVariable ["is_crate", true, true];
		[format["Grabbed Resupply! Remaining Crates/Weapons Waiting: %1", [_crate_group] call fnc_getTicketsLeft]] remoteExec ["hint", _player];
	} else {
		_crateOrWeapon = createVehicle [_crate_type, [_player, 1, 5, 2, 0, 30, 0] call BIS_fnc_findSafePos, [], 0, "CAN_COLLIDE"];
		_crateOrWeapon setVariable ["is_static_weapon", true, true];	
		[format["Grabbed Static Weapon! Remaining Crates/Weapons Waiting: %1", [_crate_group] call fnc_getTicketsLeft]] remoteExec ["hint", _player];
	};

	[_crateOrWeapon, ["ACE_maxWeightCarry", 10000]] remoteExec ["setVariable"]; 
	[_crateOrWeapon, ["ACE_maxWeightDrag", 10000]] remoteExec ["setVariable"]; 
    [_crateOrWeapon, true, [0, 2, 0], 0] remoteExec ["ace_dragging_fnc_setCarryable"]; // correct usage of remoteExec ???
	[_player, _crateOrWeapon] remoteExec ["ace_dragging_fnc_startCarry", _player];


};

