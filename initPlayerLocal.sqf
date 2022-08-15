params ["_playerUnit", "_didJIP"];

call compileFinal preprocessFileLineNumbers "inits\client.sqf"; // Client inits
call compileFinal preprocessFileLineNumbers "inits\global.sqf"; // Global inits for mainly huron containers
call compileFinal preprocessFileLineNumbers "client\experiments\electronic_warfare\index.sqf"; // Radar jamming
call compileFinal preprocessFileLineNumbers "client\applyAddActions.sqf";

ISRC_CURRENT_OBJECT_MANIPULATED = false;

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

// HEADLESS CLIENT STUFF
MANAGED_UNITS    = [];

fnc_init_addaction_manager = {
	// Manages addactions
	ISRC_my_addactions = createHashMapFromArray[
		["deploy_to_cop", false],
		["civ_ration", false],
		["commander_purchase_cop", false],
		["commander_purchase_menu", false],
		["keeper_right_vehicle", false]
	];
};

fnc_globalChat = {
	params["_message"];
	_message remoteExec ["systemChat"];		
};

fnc_globalHint = {
	params["_message"];
	_message remoteExec ["hint"];		
};

fnc_playersInRange = {
	params["_center", ["_range", 500]];
	private _players = [];
	{
		if (_x distance2D _center <= _range) then {
			_players pushBack _x;
		}
	} forEach allPlayers;
	_players
};

fnc_sayGlobal = {
	params["_sound", "_source", ["_expiration", 180], ["_range", 500]];
	private _players = [_source, _range] call fnc_playersInRange;
	{
		[_source, _sound] remoteExec ["say3D", _x];
	} forEach _players;
};

// HEADLESS CLIENT
if (!hasInterface && !isServer) exitWith {
	[] call compileFinal preprocessFileLineNumbers "headless_client\index.sqf";
	["A new headless client has been established!"] call fnc_globalChat;
};

// Check if headless client

HAS_ACTIONS  = false; // Has addactions and ace actions applied? Must happen each time player reslots.
ALLOW_DAMAGE = true;

call compileFinal preprocessFileLineNumbers "config\arsenal\baseArsenal.sqf";
call compileFinal preprocessFileLineNumbers "config\arsenal\baseArsenalAdditions.sqf";
call compileFinal preprocessFileLineNumbers "config\arsenal\specialRoles.sqf";
call compileFinal preprocessFileLineNumbers "client\logistics.sqf";
call compileFinal preprocessFileLineNumbers "config\blufor_purchase_items.sqf";
call compileFinal preprocessFileLineNumbers "config\blufor_purchase_objects.sqf";

call fnc_init_addaction_manager;

fnc_getDisplyName = {
	params ["_classname"];
	[configFile >> "CfgVehicles" >> _classname] call BIS_fnc_displayName
};

fnc_standardNumericalNotationString = {
	params["_number", ["_isMoney", true]];
	private _string = (([_number] call BIS_fnc_numberText) splitString " ") joinString ",";
	if (_isMoney) then {
		_string = format ["%1%2", CURRENCY_SYMBOL, _string];
	};
	_string
};

fnc_getFullArsenal = {

	// weapon types
	TYPE_WEAPON_PRIMARY = 1;
	TYPE_WEAPON_HANDGUN = 2;
	TYPE_WEAPON_SECONDARY = 4;
	// magazine types
	TYPE_MAGAZINE_HANDGUN_AND_GL = 16; // mainly
	TYPE_MAGAZINE_PRIMARY_AND_THROW = 256;
	TYPE_MAGAZINE_SECONDARY_AND_PUT = 512; // mainly
	TYPE_MAGAZINE_MISSILE = 768;
	// more types
	TYPE_BINOCULAR_AND_NVG = 4096;
	TYPE_WEAPON_VEHICLE = 65536;
	TYPE_ITEM = 131072;
	// item types
	TYPE_DEFAULT = 0;
	TYPE_MUZZLE = 101;
	TYPE_OPTICS = 201;
	TYPE_FLASHLIGHT = 301;
	TYPE_BIPOD = 302;
	TYPE_FIRST_AID_KIT = 401;
	TYPE_FINS = 501; // not = implemented
	TYPE_BREATHING_BOMB = 601; // not = implemented
	TYPE_NVG = 602;
	TYPE_GOGGLE = 603;
	TYPE_SCUBA = 604; // not = implemented
	TYPE_HEADGEAR = 605;
	TYPE_FACTOR = 607;
	TYPE_RADIO = 611;
	TYPE_HMD = 616;
	TYPE_BINOCULAR = 617;
	TYPE_MEDIKIT = 619;
	TYPE_TOOLKIT = 620;
	TYPE_UAV_TERMINAL = 621;
	TYPE_VEST = 701;
	TYPE_UNIFORM = 801;
	TYPE_BACKPACK = 901;	
	
	private _cargo = [
		[[], [], []], // Weapons 0, primary, secondary, handgun
		[[], [], [], []], // WeaponAccessories 1, optic,side,muzzle,bipod
		[ ], // Magazines 2
		[ ], // Headgear 3
		[ ], // Uniform 4
		[ ], // Vest 5
		[ ], // Backpacks 6
		[ ], // Goggles 7
		[ ], // NVGs 8
		[ ], // Binoculars 9
		[ ], // Map 10
		[ ], // Compass 11
		[ ], // Radio slot 12
		[ ], // Watch slot  13
		[ ], // Comms slot 14
		[ ], // WeaponThrow 15
		[ ], // WeaponPut 16
		[ ] // InventoryItems 17
	];

	private _configCfgWeapons = configFile >> "CfgWeapons"; //Save this lookup in variable for perf improvement

	{
		private _configItemInfo = _x >> "ItemInfo";
		private _simulationType = getText (_x >> "simulation");
		private _className = configName _x;
		private _hasItemInfo = isClass (_configItemInfo);
		private _itemInfoType = if (_hasItemInfo) then {getNumber (_configItemInfo >> "type")} else {0};
		private _isMiscItem = _className isKindOf ["CBA_MiscItem", (_configCfgWeapons)];

		switch true do {
			/* Weapon acc */
			case (
					_hasItemInfo &&
					{_itemInfoType in [TYPE_MUZZLE, TYPE_OPTICS, TYPE_FLASHLIGHT, TYPE_BIPOD]} &&
					{!_isMiscItem}
				): {

				//Convert type to array index
				(_cargo select 1) select ([TYPE_OPTICS,TYPE_FLASHLIGHT,TYPE_MUZZLE,TYPE_BIPOD] find _itemInfoType) pushBackUnique _className;
			};
			/* Headgear */
			case (_itemInfoType == TYPE_HEADGEAR): {
				(_cargo select 3) pushBackUnique _className;
			};
			/* Uniform */
			case (_itemInfoType == TYPE_UNIFORM): {
				(_cargo select 4) pushBackUnique _className;
			};
			/* Vest */
			case (_itemInfoType == TYPE_VEST): {
				(_cargo select 5) pushBackUnique _className;
			};
			/* NVgs */
			case (_simulationType == "NVGoggles"): {
				(_cargo select 8) pushBackUnique _className;
			};
			/* Binos */
			case (_simulationType == "Binocular" ||
			((_simulationType == 'Weapon') && {(getNumber (_x >> 'type') == TYPE_BINOCULAR_AND_NVG)})): {
				(_cargo select 9) pushBackUnique _className;
			};
			/* Map */
			case (_simulationType == "ItemMap"): {
				(_cargo select 10) pushBackUnique _className;
			};
			/* Compass */
			case (_simulationType == "ItemCompass"): {
				(_cargo select 11) pushBackUnique _className;
			};
			/* Radio */
			case (_simulationType == "ItemRadio"): {
				(_cargo select 12) pushBackUnique _className;
			};
			/* Watch */
			case (_simulationType == "ItemWatch"): {
				(_cargo select 13) pushBackUnique _className;
			};
			/* GPS */
			case (_simulationType == "ItemGPS"): {
				(_cargo select 14) pushBackUnique _className;
			};
			/* UAV terminals */
			case (_itemInfoType == TYPE_UAV_TERMINAL): {
				(_cargo select 14) pushBackUnique _className;
			};
			/* Weapon, at the bottom to avoid adding binos */
			case (isClass (_x >> "WeaponSlotsInfo") &&
				{getNumber (_x >> 'type') != TYPE_BINOCULAR_AND_NVG}): {
				switch (getNumber (_x >> "type")) do {
					case TYPE_WEAPON_PRIMARY: {
						(_cargo select 0) select 0 pushBackUnique (_className call bis_fnc_baseWeapon);
					};
					case TYPE_WEAPON_HANDGUN: {
						(_cargo select 0) select 2 pushBackUnique (_className call bis_fnc_baseWeapon);
					};
					case TYPE_WEAPON_SECONDARY: {
						(_cargo select 0) select 1 pushBackUnique (_className call bis_fnc_baseWeapon);
					};
				};
			};
			/* Misc items */
			case (
					_hasItemInfo &&
					(_itemInfoType in [TYPE_MUZZLE, TYPE_OPTICS, TYPE_FLASHLIGHT, TYPE_BIPOD] &&
					{_isMiscItem}) ||
					{_itemInfoType in [TYPE_FIRST_AID_KIT, TYPE_MEDIKIT, TYPE_TOOLKIT]} ||
					{(getText ( _x >> "simulation")) == "ItemMineDetector"}
				): {
				(_cargo select 17) pushBackUnique _className;
			};
		};
	} foreach configProperties [_configCfgWeapons, "isClass _x && {(if (isNumber (_x >> 'scopeArsenal')) then {getNumber (_x >> 'scopeArsenal')} else {getNumber (_x >> 'scope')}) == 2} && {getNumber (_x >> 'ace_arsenal_hide') != 1}", true];

	private _grenadeList = [];
	{
		_grenadeList append getArray (_configCfgWeapons >> "Throw" >> _x >> "magazines");
	} foreach getArray (_configCfgWeapons >> "Throw" >> "muzzles");

	private _putList = [];
	{
		_putList append getArray (_configCfgWeapons >> "Put" >> _x >> "magazines");
	} foreach getArray (_configCfgWeapons >> "Put" >> "muzzles");

	{
		private _className = configName _x;

		switch true do {
			// Grenades
			case (_className in _grenadeList): {
				(_cargo select 15) pushBackUnique _className;
			};
			// Put
			case (_className in _putList): {
				(_cargo select 16) pushBackUnique _className;
			};
			// Rifle, handgun, secondary weapons mags
			case (
					(getNumber (_x >> "type") in [TYPE_MAGAZINE_PRIMARY_AND_THROW,TYPE_MAGAZINE_SECONDARY_AND_PUT,1536,TYPE_MAGAZINE_HANDGUN_AND_GL,TYPE_MAGAZINE_MISSILE])
				): {
				(_cargo select 2) pushBackUnique _className;
			};
		};
	} foreach configProperties [(configFile >> "CfgMagazines"), "isClass _x && {(if (isNumber (_x >> 'scopeArsenal')) then {getNumber (_x >> 'scopeArsenal')} else {getNumber (_x >> 'scope')}) == 2} && {getNumber (_x >> 'ace_arsenal_hide') != 1}", true];

	{
		if (getNumber (_x >> "isBackpack") == 1) then {
			(_cargo select 6) pushBackUnique (configName _x);
		};
	} foreach configProperties [(configFile >> "CfgVehicles"), "isClass _x && {(if (isNumber (_x >> 'scopeArsenal')) then {getNumber (_x >> 'scopeArsenal')} else {getNumber (_x >> 'scope')}) == 2} && {getNumber (_x >> 'ace_arsenal_hide') != 1}", true];

	{
		(_cargo select 7) pushBackUnique (configName _x);
	} foreach configProperties [(configFile >> "CfgGlasses"), "isClass _x && {(if (isNumber (_x >> 'scopeArsenal')) then {getNumber (_x >> 'scopeArsenal')} else {getNumber (_x >> 'scope')}) == 2} && {getNumber (_x >> 'ace_arsenal_hide') != 1}", true];

	private _magazineGroups = createHashMap;

	private _cfgMagazines = configFile >> "CfgMagazines";

	{
		private _magList = [];
		{
			private _magazines = (getArray _x) select {isClass (_cfgMagazines >> _x)}; //filter out non-existent magazines
			_magazines = _magazines apply {configName (_cfgMagazines >> _x)}; //Make sure classname case is correct
			_magList append _magazines;
		} foreach configProperties [_x, "isArray _x", true];

		_magazineGroups set [toLower configName _x, _magList arrayIntersect _magList];
	} foreach configProperties [(configFile >> "CfgMagazineWells"), "isClass _x", true];

	_cargo	
};

// Get GroupID
_groupId  = groupId group player;

fnc_applyActions = {
    // Intro Briefing
    [] call compileFinal preprocessFileLineNumbers "client\proceduralMessage.sqf";
    // Ace Actions
    [] call compileFinal preprocessFileLineNumbers "client\applyAceActions.sqf";
    HAS_ACTIONS = true;
};

_name     = name player;
_groupId  = groupId group player;
_roledesc = roleDescription player;

if ("Bishop" in roleDescription player) then {
	systemChat "[Bishop] Added module to Zeus: ISRC Bishop";
	[] call compileFinal preprocessFileLineNumbers "client\applyZeusActions.sqf";
};

if (["bishop", _groupId] call BIS_fnc_inString) then {
    [] spawn {
        private _admins = [missionNamespace, "ADMINS", []] call BIS_fnc_getServerVariable;
        if !((getPlayerUID player) in _admins) then
        {
            ["ZeusInvalidPerms", false, true] call BIS_fnc_endMission;
        };
    };
};

private _roledesc_0 = _roledesc splitString "@";
private _roledesc_1 = _roledesc_0 select 0;
[ format["[%1] %2: %3 just deployed.", _groupId, _name, _roledesc_1] ] call fnc_globalChat;


//////// TESTS ////

// ELECTRONIC WARFARE
call ISRCEWS_fnc_init; // Todo: Make dedicated EW role and lock this feature to it!