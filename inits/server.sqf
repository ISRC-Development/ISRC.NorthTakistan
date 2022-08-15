if (!isServer) exitWith {};

// Init for Ammo containers - server
["B_Slingload_01_Ammo_F", "init",
{ 
	private _container = _this select 0;
	[_container, 10000000] call ace_rearm_fnc_makeSource;
	_container setVariable ["IS_PROP", true];
},
true,
[],
true
] call CBA_fnc_addClassEventHandler;

// Init for Arsenal Crates - server
["B_supplyCrate_F", "init",
{ 
	private _thing = _this select 0;
	_thing setVariable ["IS_PROP", true];
},
true,
[],
true
] call CBA_fnc_addClassEventHandler;

// Init for LOGIPOINT - server
[LOGI_POINT_CLASSNAME, "init",
{ 
	private _thing = _this select 0;
	_thing setVariable ["IS_PROP", true];
},
true,
[],
true
] call CBA_fnc_addClassEventHandler;

// Init for Cargo House - server
["Land_Cargo_House_V1_F", "init",
{ 
	private _thing = _this select 0;
	_thing setVariable ["IS_PROP", true];
},
true,
[],
true
] call CBA_fnc_addClassEventHandler;

// Init for Cargo House - server
["B_Slingload_01_Fuel_F", "init",
{ 
	private _thing = _this select 0;
	_thing setVariable ["IS_PROP", true];
	[_thing, 10000000] call ace_refuel_fnc_makeSource;
},
true,
[],
true
] call CBA_fnc_addClassEventHandler;

// Init for repair container - server
["B_Slingload_01_Repair_F", "init",
{ 
	private _thing = _this select 0;
	_thing setVariable ["IS_PROP", true];
	_thing setVariable ["ACE_isRepairFacility", true];
},
true,
[],
true
] call CBA_fnc_addClassEventHandler;

systemChat "set server inits";



