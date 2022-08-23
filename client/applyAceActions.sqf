// ROOT MENU - SUPPLY CRATES
[LOGI_POINT_CLASSNAME, 0, ["ACE_MainActions"], [ "supplyRootMenu", "Supply Crates", "", {}, {true}] call ace_interact_menu_fnc_createAction] call ace_interact_menu_fnc_addActionToClass; 

CRATE_PRIVS = createHashMapFromArray [
	["MEDICAL", false],
	["MIXED",   false],
	["AT",      false],
	["EMPTY",   false],
	["STATIC", false]
];

private _role = roleDescription player;
if (leader group player == player) then {
	if ("medic" in _role || "Banshee" in _role || "surgeon" in _role) then {
		CRATE_PRIVS set ["MEDICAL", true];
	};
	if ("1-1" in _role || "1-2" in _role) then {
		CRATE_PRIVS set ["MIXED", true];
	};
	if ("1-2" in _role) then {
		CRATE_PRIVS set ["AT", true];
		CRATE_PRIVS set ["STATIC", true];
	};
	if ("Legion 6" in _role || "Legion 7" in _role) then {
		CRATE_PRIVS set ["MIXED", true];
	};
	if ("Legion 8" in _role) then {
		CRATE_PRIVS set ["MEDICAL", true];
	};
	if ("Keeper" in _role) then {
		CRATE_PRIVS set ["MEDICAL", true];
		CRATE_PRIVS set ["MIXED",   true];
		CRATE_PRIVS set ["AT",      true];
		CRATE_PRIVS set ["EMPTY",   true];
		CRATE_PRIVS set ["STATIC",  true];
	};
	if ("Bishop" in _role) then {
		CRATE_PRIVS set ["MEDICAL", true];
		CRATE_PRIVS set ["MIXED",   true];
		CRATE_PRIVS set ["AT",      true];
		CRATE_PRIVS set ["EMPTY",   true];
		CRATE_PRIVS set ["STATIC",  true];
	};
	if ( "Phantom" in _role ) then {
		CRATE_PRIVS set ["MEDICAL", true];
		CRATE_PRIVS set ["MIXED",   true];
		CRATE_PRIVS set ["STATIC",  true];
	};	
	if ( "Witchdoctor" in _role ) then {
		CRATE_PRIVS set ["STATIC", true];
	};

	//systemChat format ["Has access to %1.", CRATE_PRIVS];

	if (CRATE_PRIVS get "MEDICAL") then {
		[LOGI_POINT_CLASSNAME , 0, ["ACE_MainActions", "supplyRootMenu"], [
			"medical_resupply",
			"Medical Resupply",
			"",
			{
				[player, "medical_resupply"] remoteExec ["fnc_pullCrateServer", 2];
			}, {true},{},[], [0,0,0], 100] call ace_interact_menu_fnc_createAction] call ace_interact_menu_fnc_addActionToClass;     
	};

	if (CRATE_PRIVS get "MIXED") then { 
		[LOGI_POINT_CLASSNAME , 0, ["ACE_MainActions", "supplyRootMenu"], [
			"general_resupply",
			"Mixed Resupply",
			"",
			{
				[player, "general_resupply"] remoteExec ["fnc_pullCrateServer", 2];
			}, {true},{},[], [0,0,0], 100] call ace_interact_menu_fnc_createAction] call ace_interact_menu_fnc_addActionToClass; 
	};

	if (CRATE_PRIVS get "AT") then { 
		[LOGI_POINT_CLASSNAME , 0, ["ACE_MainActions", "supplyRootMenu"], [
			"at_resupply",
			"AT Resupply",
			"",
			{
				[player, "at_resupply"] remoteExec ["fnc_pullCrateServer", 2];
			}, {true},{},[], [0,0,0], 100] call ace_interact_menu_fnc_createAction] call ace_interact_menu_fnc_addActionToClass; 
	};

	if (CRATE_PRIVS get "EMPTY") then { 
		[LOGI_POINT_CLASSNAME , 0, ["ACE_MainActions", "supplyRootMenu"], [
			"empty_resupply",
			"Empty Resupply",
			"",
			{
				[player, "empty_resupply"] remoteExec ["fnc_pullCrateServer", 2];
			}, {true},{},[], [0,0,0], 100] call ace_interact_menu_fnc_createAction] call ace_interact_menu_fnc_addActionToClass; 
	};

	if (CRATE_PRIVS get "STATIC") then { 

		// ROOT MENU - STATIC WEAPONS
		[LOGI_POINT_CLASSNAME, 0, ["ACE_MainActions"], [ "staticWeapRootMenu", "Static Weapons", "", {}, {true}] call ace_interact_menu_fnc_createAction] call ace_interact_menu_fnc_addActionToClass; 


		// STATIC WEAPONS SPAWNER
		[LOGI_POINT_CLASSNAME , 0, ["ACE_MainActions", "staticWeapRootMenu"], [
			"Grab TOW Launcher",
			"TOW Launcher",
			"",
			{ ////////////
				[player, "RHS_TOW_TriPod_WD", true] remoteExec ["fnc_pullCrateServer", 2];
			}, {true},{},[], [0,0,0], 100] call ace_interact_menu_fnc_createAction] call ace_interact_menu_fnc_addActionToClass;      

		[LOGI_POINT_CLASSNAME , 0, ["ACE_MainActions", "staticWeapRootMenu"], [
			"Grab AA Pod",
			"AA Pod",
			"",
			{
				[player, "RHS_Stinger_AA_pod_USMC_D", true] remoteExec ["fnc_pullCrateServer", 2];
			}, {true},{},[], [0,0,0], 100] call ace_interact_menu_fnc_createAction] call ace_interact_menu_fnc_addActionToClass;   

		[LOGI_POINT_CLASSNAME , 0, ["ACE_MainActions", "staticWeapRootMenu"], [
			"Grab MK19",
			"MK19",
			"",
			{
				[player, "RHS_MK19_TriPod_USMC_D", true] remoteExec ["fnc_pullCrateServer", 2];
			}, {true},{},[], [0,0,0], 100] call ace_interact_menu_fnc_createAction] call ace_interact_menu_fnc_addActionToClass;

		[LOGI_POINT_CLASSNAME , 0, ["ACE_MainActions", "staticWeapRootMenu"], [
			"Grab Mortar",
			"Mortar",
			"",
			{
				[player, "B_T_Mortar_01_F", true] remoteExec ["fnc_pullCrateServer", 2];
			}, {true},{},[], [0,0,0], 100] call ace_interact_menu_fnc_createAction] call ace_interact_menu_fnc_addActionToClass;    

		[LOGI_POINT_CLASSNAME , 0, ["ACE_MainActions", "staticWeapRootMenu"], [
			"Grab M2 Static",
			"M2 Static",
			"",
			{
				[player, "RHS_M2StaticMG_D", true] remoteExec ["fnc_pullCrateServer", 2];
			}, {true},{},[], [0,0,0], 100] call ace_interact_menu_fnc_createAction] call ace_interact_menu_fnc_addActionToClass;       

		[LOGI_POINT_CLASSNAME , 0, ["ACE_MainActions", "staticWeapRootMenu"], [
			"Grab M2 Static Mini",
			"M2 Static Mini",
			"",
			{
				[player, "RHS_M2StaticMG_MiniTripod_D", true] remoteExec ["fnc_pullCrateServer", 2];
			}, {true},{},[], [0,0,0], 100] call ace_interact_menu_fnc_createAction] call ace_interact_menu_fnc_addActionToClass;  

	};

	// ROOT MENU - CHECK TICKETS
	[LOGI_POINT_CLASSNAME, 0, ["ACE_MainActions"], [ "checkTicketsRootMenu", "Check Stock", "", {
		[[player], "server\client_ui_callbacks\fnc_getCrateTickets.sqf"] remoteExec ["execVM", 2];
	}, {true}] call ace_interact_menu_fnc_createAction] call ace_interact_menu_fnc_addActionToClass; 

};

// Check Misc. Info
_action = ["actionCheckSectors","Liberation Info","", {execVM "client\fnc_showCurrentInfo.sqf";}, {true}] call ace_interact_menu_fnc_createAction;
[player, 1, ["ACE_SelfActions"], _action] call ace_interact_menu_fnc_addActionToObject;

// classname, name, reward
{
	private _thisItem = LOGISTICS_SUPPLIES_CLASSES get _x;
	private _classname  = _thisItem get "classname";
	private _id 	    = format["action_%1", _x];
	private _rootMenuId = format["supplyRootMenu_%1", _id]; 

	// ROOT MENU
	[_classname, 0, ["ACE_MainActions"], [
		_rootMenuId,
		"Logistics",
		"",
		{},
		{true}] call ace_interact_menu_fnc_createAction] call ace_interact_menu_fnc_addActionToClass; 

	// LOAD SUPPLY INTO RECIPROCLE AND COLLECT REWARD
	private _action   = [
	_id,
	"Collect Reward For " + (_thisItem get "name"),
	"",
	{
		{
			if (typeOf _x in (call fnc_getAllSuppllyClasses)) exitWith {

				private _hmap   = [typeOf _x] call fnc_getLogiSupplyHMAPbyClassName; // Not working???
				private _reward = _hmap get "reward";
				private _name   = _hmap get "name";
				private _class  = typeOf _x;

				deleteVehicle _x; // Delete supply

				if (typeName _reward != "SCALAR") then {
					systemChat "Error: Climed item has no reward variable, defaulting to 100k...";
					[100000] remoteExec ["fnc_addToFunding", 2];
					["IntelGreen", [format ["New Funding: <br/>$%1", [100000] call fnc_standardNotation]]] remoteExec ["BIS_fnc_showNotification", -2];
				} else {
					// Reward - Get paid
					[_reward] remoteExec ["fnc_addToFunding", 2];
					hint format["Reward claimed for $%1!", _reward];
					["IntelGreen", [format ["New Funding: <br/>$%1", [_reward] call fnc_standardNotation]]] remoteExec ["BIS_fnc_showNotification", -2];
				};

			};
		} forEach nearestObjects [player, [], 10];
	}, {(count (nearestObjects [getPos player, [LOGISTICS_SUPPLIES_RECIPROCAL_CLASSNAME], 15]) > 0)},{},[], [0,0,0], 100] call ace_interact_menu_fnc_createAction;
	[_classname, 0, ["ACE_MainActions", _rootMenuId], _action] call ace_interact_menu_fnc_addActionToClass;

	// LOAD SUPPLY INTO VEHICLE
	private _action   = [
	_id,
	format["Load %1 Into Nearest Applicable Vehicle", _thisItem get "name"],
	"",
	{
		params ["_target", "_player", "_params"];
		private _loaded = false;
		private _hmap = [typeOf _target] call fnc_getLogiSupplyHMAPbyClassName;
		{
			private _type = typeOf _x;
			private _can  = _x canVehicleCargo _target;
			if (!(_loaded) && ( (_type isKindOf "Car") || (_type isKindOf "Truck") ) && (_can select 0)) then {
				_x setVehicleCargo _target;
				_loaded = true;
			};
		} forEach nearestObjects [player, [], 15];
		if !(_loaded) then {
			hint "No applicable vehicle found!";
		};
	}, {true},{},[], [0,0,0], 100] call ace_interact_menu_fnc_createAction;
	[_classname, 0, ["ACE_MainActions", _rootMenuId], _action] call ace_interact_menu_fnc_addActionToClass;	

	//systemChat format ["%1 - %2", _classname, _id];   

} forEach LOGISTICS_SUPPLIES_CLASSES;