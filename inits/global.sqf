// Do init for our fuel containers
["B_Slingload_01_Fuel_F", "init",
{ 
	private _container = _this select 0;	
	_container setVariable ["IS_PROP", true];
	_container setVariable ["isrc_engineer_movable", true];
	_container allowDamage false;
	if (isServer) then {
		[_container, 10000000] call ace_refuel_fnc_makeSource;
	};
},
true,
[],
true
] call CBA_fnc_addClassEventHandler;

// Do init for our cargo containers
["B_Slingload_01_Cargo_F", "init",
{ 
	private _container = _this select 0;	
	_container setVariable ["is_prop", true];
	_container setVariable ["isrc_engineer_movable", true];
	_container allowDamage false;
},
true,
[],
true
] call CBA_fnc_addClassEventHandler;

// Init for repair container - client
["B_Slingload_01_Repair_F", "init",
{ 
	private _container = _this select 0;	
	_container setVariable ["ACE_isRepairFacility", 1];
	_container setVariable ["is_prop", true];
	_container setVariable ["isrc_engineer_movable", true];
	_container allowDamage false;
},
true,
[],
true
] call CBA_fnc_addClassEventHandler;

// Do init for Ammo containers - client
["B_Slingload_01_Ammo_F", "init",
{ 
	private _container = _this select 0;	
	_container setVariable ["is_prop", true];
	_container setVariable ["isrc_engineer_movable", true];
	_container allowDamage false;
	if (isServer) then {
		[_container, 10000000] call ace_rearm_fnc_makeSource;
	};
},
true,
[],
true
] call CBA_fnc_addClassEventHandler;