if (isServer && !hasInterface) exitWith {};

call compileFinal preprocessFileLineNumbers "config\arsenal\military_gear_pack\index.sqf";

["B_supplyCrate_F", "init",
    { 
        private _box = (_this select 0);
		[{
			private _box = (_this select 0);
			clearMagazineCargoGlobal _box;
			clearItemCargoGlobal _box;
			clearBackpackCargoGlobal _box;
			clearWeaponCargoGlobal _box;

			// Initially remove any existing virtual boxes
			[_box, false] call ace_arsenal_fnc_removeBox;

			_box setVariable ["ace_cargo_noRename", true];

			private _baseArsenal_clean = flatten ISRC_base_arsenal;

			// Removes role-restricted items from base arsenal
			{
				_baseArsenal_clean = _baseArsenal_clean - [_x]; 			
			} forEach ISRC_arsenal_all;

			private _myArsenal = _baseArsenal_clean + ISRC_base_arsenal_additions;
			
			// Specialists
			if ("Leader" in (roleDescription player)) then {
				_myArsenal = _myArsenal + ISRC_arsenal_squad_leader + MILGP_HQ;
			};						
			if ("AT" in (roleDescription player)) then {
				_myArsenal = _myArsenal + ISRC_arsenal_at_spec;
			};
			if ("Marksman" in (roleDescription player) || "Recon Sniper" in (roleDescription player) || "Recon Spotter" in (roleDescription player)) then {
				_myArsenal = _myArsenal + ISRC_arsenal_marksman + MILGP_MARKSMAN;
			};
			if ("Medic" in (roleDescription player)) then {
				_myArsenal = _myArsenal + ISRC_arsenal_medical + MILGP_MEDIC;
			};
			if (("Automatic" in (roleDescription player) || ("Machine" in (roleDescription player)))) then {
				_myArsenal = _myArsenal + ISRC_arsenal_machinegunner;
			};
			if ("Grenadier" in (roleDescription player)) then {
				_myArsenal = _myArsenal + ISRC_arsenal_grenedier + MILGP_GRENADIER;
			};

			// Elements
			if ("Hammer" in (roleDescription player)) then {
				_myArsenal = _myArsenal + ISRC_arsenal_crew + ISRC_arsenal_squad_leader;
			};			
			if ("Stalker " in (roleDescription player)) then {
				_myArsenal = _myArsenal + ISRC_arsenal_rotary_pilot + MILGP_AIR + ISRC_arsenal_squad_leader;
			};
			if ("Hog" in (roleDescription player) || "Pilot" in (roleDescription player) || "Copilot" in (roleDescription player)) then {
				_myArsenal = _myArsenal + ISRC_arsenal_fixedw_pilot + MILGP_AIR + ISRC_arsenal_squad_leader;
			};		

			// Command	
			if (
				"Legion 6" in (roleDescription player)
				|| "Legion 7" in (roleDescription player)
				|| "Legion 8" in (roleDescription player)
				|| "Legion 1-6" in (roleDescription player)
			) then {
				_myArsenal = _myArsenal + ISRC_arsenal_hq + MILGP_HQ;
			};

			// Detachments
			if ("Banshee" in (roleDescription player) || "Legion 8" in (roleDescription player)) then {
				_myArsenal = _myArsenal + ISRC_arsenal_medical + ISRC_arsenal_medical_adv + MILGP_MEDIC + ISRC_arsenal_squad_leader;
			};
			if ("Keeper" in (roleDescription player)) then {
				_myArsenal = _myArsenal + ISRC_arsenal_engineer + ISRC_arsenal_squad_leader + MILGP_HQ;
			};
			if ("Phantom" in (roleDescription player)) then {
				_myArsenal = _myArsenal + ISRC_arsenal_squad_leader + MILGP_HQ + [
					"U_B_FullGhillie_lsh",
					"U_B_FullGhillie_sard",
					"U_B_FullGhillie_ard",
					"U_O_FullGhillie_lsh",
					"U_O_FullGhillie_sard",
					"U_O_FullGhillie_ard",
					"U_I_FullGhillie_lsh",
					"U_I_FullGhillie_sard",
					"U_I_FullGhillie_ard",
					"U_B_T_FullGhillie_tna_F",
					"U_O_T_FullGhillie_tna_F"
				];
			};
			if ("Witchdoctor" in (roleDescription player)) then {
				_myArsenal = _myArsenal + ISRC_arsenal_idf + ISRC_arsenal_hq;
			};

			_myArsenal = _myArsenal + MILGP_BASE; // military gear pack base

			// Do the damn thing
			[_box, _myArsenal, false] call ace_arsenal_fnc_initBox;

			//systemChat format["Role Arsenal: %1 - Items: %2", _box, count _myArsenal];
		}, [_box], 5] call CBA_fnc_waitAndExecute;

    },
    true,
    [],
    true
] call CBA_fnc_addClassEventHandler;

LOGISTICS_SUPPLIES_CLASSES = createHashMapFromArray[
	[
		"cargo_net",
		createHashMapFromArray[ ["classname", "CargoNet_01_box_F"], ["name", "Supplies"], ["reward", 100000], ["cargo_size", 6]]
	],
    [
        "fuel_net",
        createHashMapFromArray[ ["classname", "CargoNet_01_barrels_F"], ["name", "Fuel"], ["reward", 150000], ["cargo_size", 6]]
    ]
];

/*
// Do inits for our logi supplies
{
	private _thisItem  = LOGISTICS_SUPPLIES_CLASSES get _x;
	private _classname = _thisItem get "classname";
	private _id 	   = format["action_%1", _x];
	[_classname, "init",
    { 
		private _box = (_this select 0);
		[{
			private _item 	  = (_this select 0);
			private _hmap     = [typeOf _item] call fnc_getLogiSupplyHMAPbyClassName;

			clearMagazineCargoGlobal _item;
			clearItemCargoGlobal 	 _item;
			clearBackpackCargoGlobal _item;
			clearWeaponCargoGlobal 	 _item;

			_item setVariable ["ace_cargo_noRename", true];
			_item setVariable ["ace_cargo_canLoad", 1];
			_item enableVehicleCargo true;

			[_item, _hmap get "cargo_size"] call ace_cargo_fnc_setSize;

		}, [_box], 5] call CBA_fnc_waitAndExecute;
    },
    true,
    [],
    true
	] call CBA_fnc_addClassEventHandler;

} forEach createHashMapFromArray[
	[
		"cargo_net",
		createHashMapFromArray[ ["classname", "CargoNet_01_box_F"], ["name", "Supplies"], ["reward", 50000], ["cargo_size", 6]]
	],
    [
        "fuel_net",
        createHashMapFromArray[ ["classname", "CargoNet_01_barrels_F"], ["name", "Fuel"], ["reward", 10000], ["cargo_size", 6]]
    ]
];
*/

// Do init for our logi reciprocal
["B_Slingload_01_Cargo_F", "init",
{ 
	private _box = (_this select 0);
	_box allowDamage false;
},
true,
[],
true
] call CBA_fnc_addClassEventHandler;

// Do init for our logi reciprocal
["Land_Cargo_House_V1_F", "init",
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

// Init for HEMTT Flatbed (vanilla)
["B_T_Truck_01_flatbed_F", "init",
{ 
	private _thing = _this select 0;
	_thing enableVehicleCargo true;
},
true,
[],
true
] call CBA_fnc_addClassEventHandler;

systemChat "set client inits";
