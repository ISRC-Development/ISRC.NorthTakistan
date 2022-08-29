private _m = "1SRC Bishop";

if !([_m, "Misc: Bypass Cleanup Script", {
	_pos        = _this select 0;
	_zen_target = _this select 1;
	if (isNull _zen_target) exitWith {hint "Error: Place on an object!"};
	// [_zen_target, "IS_PROP", true] call BIS_fnc_setServerVariable;
	[_zen_target, ["IS_PROP", true]] remoteExec ["setVariable", 2, _zen_target];
	hint "Success: Bypass Cleanup Script enabled for the object!";
}, "\a3\modules_f\data\iconSavegame_ca.paa"] call zen_custom_modules_fnc_register) then {
	systemChat "[Bishop] Failed to add Zeus module feature: Bypass Cleanup Script";
};

if !([_m, "Logi: Get Empty Crate", {
	private _crate = "Box_NATO_Equip_F" createVehicle (_this select 0);
	clearMagazineCargoGlobal _crate;
	clearItemCargoGlobal _crate;
	clearBackpackCargoGlobal _crate;
	clearWeaponCargoGlobal _crate;	
	[_crate, "IS_PROP", true] remoteExec ["setVariable", 2]; 
}, "\a3\modules_f\data\iconTaskCreate_ca.paa"] call zen_custom_modules_fnc_register) then {
	systemChat "[Bishop] Failed to add Zeus module feature: Get Empty Crate";
};

if !([_m, "Logi: Get Arsenal", {
	private _crate = "B_supplyCrate_F" createVehicle (_this select 0);
	clearMagazineCargoGlobal _crate;
	clearItemCargoGlobal _crate;
	clearBackpackCargoGlobal _crate;
	clearWeaponCargoGlobal _crate;	
	[_crate, "IS_PROP", true] remoteExec ["setVariable", 2]; 
}, "\a3\modules_f\data\iconTaskCreate_ca.paa"] call zen_custom_modules_fnc_register) then {
	systemChat "[Bishop] Failed to add Zeus module feature: Get Arsenal";
};

if !([_m, "Misc: Create IED", {

	_zen_pos    = _this select 0;
	_zen_target = _this select 1;

	/*
	# Paramters:
		> 0: classname - string
		> 1: position - array
		> 2: detonation radius - number
		> 3: vehicle - bool or string
		> 4: debug - bool
		> 5: targeting radius - number
		> 6: deadman switch - bool
		> 7: side - side
		> 8: audio - bool
		> 9: add gear - bool
		> 10: explosion type - string
		> 11: interval - number
		> 12: isfemale - bool
	*/

	if !([
		"Bishop: Create IED",
		[
			[ // 0
				"COMBO",
				["IED", "Select an IED type"],
				[
					["IEDLandBig_F","IEDLandSmall_F","IEDUrbanBig_F","IEDUrbanSmall_F"],
					["IEDLandBig_F","IEDLandSmall_F","IEDUrbanBig_F","IEDUrbanSmall_F"],
					0
				],
				false
			]
		],
		{
			// On Accept //

			// User-Provided Settings
			private _user_set = _this select 0;

			// Args
			private _args      = _this select 1;
			private _pos       = _args select 0;
			private _targetObj = _args select 1; // Not used in this scope - creating new object here.

			// Default Values //
			private _classname  = _user_set select 0;

			private _ied_obj = createMine [_classname, [_pos select 0, _pos select 1, 0], [], 0]; // getTerrainHeightASL [_pos select 0, _pos select 1]
			_ied_obj setdir (random 360);
			_ied_obj setVectorUp surfaceNormal (getposATL _ied_obj);

			[_ied_obj] spawn {
				params["_ied_obj"];
				private _exploded = false;
				while {!(_exploded) && (alive _ied_obj)} do {
					sleep 2;
					if (count (ASLToAGL getPosASL _ied_obj nearEntities [["Man", "Car", "Motorcycle", "Tank", "Truck"], 25]) > 0) then {
						_exploded = true;
						_ied_obj setDamage 1;
					};
				};
			};
			
			hint "Success: IED created!";
			
		},
		{hint "Bishop: Action Canceled"},
		[_this select 0, _this select 1]
	] call zen_dialog_fnc_create) then {hint "Bishop: Failed To Create IED"};	
}, "\a3\modules_f\data\iconTaskCreate_ca.paa"] call zen_custom_modules_fnc_register) then {
	systemChat "[Bishop] Failed to add Zeus module feature: Create IED";
};

if !([_m, "Logi: Gift Logi Supplies", {

	_zen_pos    = _this select 0;
	_zen_target = _this select 1;

	/*
	# Paramters:
		> 0: classname - string
		> 1: position - array
		> 2: detonation radius - number
		> 3: vehicle - bool or string
		> 4: debug - bool
		> 5: targeting radius - number
		> 6: deadman switch - bool
		> 7: side - side
		> 8: audio - bool
		> 9: add gear - bool
		> 10: explosion type - string
		> 11: interval - number
		> 12: isfemale - bool
	*/

	if !([
		"Bishop: Gift Logi Supplies",
		[
			[ // 0
				"COMBO",
				["Supplies", "Select a logi supply type to spawn"],
				[
					ZEUS_LOGISTICS_SUPPLIES_CLASSES,
					["Drug Crate", "Stolen Supplies", "Drug Shipment"],
					0
				],
				false
			]
		],
		{
			// On Accept //

			// User-Provided Settings
			private _user_set = _this select 0;

			// Args
			private _args      = _this select 1;
			private _pos       = _args select 0;
			private _targetObj = _args select 1; // Not used in this scope - creating new object here.

			// Default Values //
			private _classname  = _user_set select 0;

			private _obj = _classname createVehicle _pos;	

			[_obj, "IS_PROP", true] remoteExec ["setVariable", 2]; 
			
			hint "Success: Spawned!";
			
		},
		{hint "Bishop: Action Canceled"},
		[_this select 0, _this select 1]
	] call zen_dialog_fnc_create) then {hint "Bishop: Failed To Spawn!"};	
}, "\a3\modules_f\data\iconTaskCreate_ca.paa"] call zen_custom_modules_fnc_register) then {
	systemChat "[Bishop] Failed to add Zeus module feature: Gift Logi Supplies";
};

if !([_m, "Misc: Global Intel", {

	_zen_pos    = _this select 0;
	_zen_target = _this select 1;

	/*
	# Paramters:
		> 0: classname - string
		> 1: position - array
		> 2: detonation radius - number
		> 3: vehicle - bool or string
		> 4: debug - bool
		> 5: targeting radius - number
		> 6: deadman switch - bool
		> 7: side - side
		> 8: audio - bool
		> 9: add gear - bool
		> 10: explosion type - string
		> 11: interval - number
		> 12: isfemale - bool
	*/

if !([
		"Bishop: Global Intel",
		[
			[ // 0
				"EDIT:MULTI",
				["Intel", "Enter your message"],
				[
					"Hello World!",
					{},
					6
				],
				false
			]
		],
		{
			// On Accept //
			// User-Provided Settings
			private _user_set = _this select 0;

			// Args
			private _args      = _this select 1;
			private _pos       = _args select 0;
			private _targetObj = _args select 1;

			["Intel", [_user_set select 0]] remoteExec ["BIS_fnc_showNotification"];

		},
		{hint "Bishop: Action Canceled"},
		[_this select 0, _this select 1]
	] call zen_dialog_fnc_create) then {hint "Bishop: Failed To Spawn!"};	
}, "\a3\modules_f\data\iconHQ_ca.paa"] call zen_custom_modules_fnc_register) then {
	systemChat "[Bishop] Failed to add Zeus module feature: Global Intel";
};

if !([_m, "Troll: Ragdoll Unit", {

	_zen_pos    = _this select 0;
	_zen_target = _this select 1;

	if !(isNull _zen_target) then {
		if ( (_zen_target isKindOf "Man") ) then {
			_zen_target addForce [[0,1000,0],[1,0,0]];	
		};
	};

}, "\a3\modules_f\data\icon_effects_ca.paa"] call zen_custom_modules_fnc_register) then {
	systemChat "[Bishop] Failed to add Zeus module feature: Ragdoll Unit";
};

if !([_m, "Troll: Get ARMA'D", {

	_zen_pos    = _this select 0;
	_zen_target = _this select 1;

	for "_i" from 0 to 45 do {
		_zen_target addForce [[0,10000,0],[0,0,1]];
	};

}, "\a3\modules_f\data\icon_effects_ca.paa"] call zen_custom_modules_fnc_register) then {
	systemChat "[Bishop] Failed to add Zeus module feature: Get ARMA'D";
};

/*
if !([_m, "Headless Client: Toggle Active", {
	[] remoteExec ["fnc_toggleHCL", 2];
}, "\a3\modules_f\data\icon_HC_ca.paa"] call zen_custom_modules_fnc_register) then {
	systemChat "[Bishop] Failed to add Zeus module feature: Toggle Active";
};
*/

if !([_m, "Headless Client: Manage Group", {
		_zen_pos    = _this select 0;
		_zen_target = _this select 1;
		if (_zen_target isKindOf "Man") then {
			private _group = group _zen_target;
			if (isPlayer leader _group) exitWith {
				hint "Error: Headless Client can't manage players!"
			};
			_group setGroupOwner (owner hc1);
			hint "Group was transfered to the Headless Client!";
		} else {
			hint "Error: No object/invalid object selected!";
		};
}, "\a3\modules_f\data\icon_HC_ca.paa"] call zen_custom_modules_fnc_register) then {
	systemChat "[Bishop] Failed to add Zeus module feature: Manage Group";
};

/*
if !([_m, "Misc: Create Suicide Bomber", {
		_zen_pos    = _this select 0;
		_zen_target = _this select 1;
		if (_zen_target isKindOf "Man") then {
			private _group = group _zen_target;
			_group setOwner player;
			[_group] execVM "functions\server\ssb.sqf";
			hint format ["%1 is now a suicide bomber!", name leader _group];
		} else {
			hint "Error: Drop the module on a unit!";
		};
}, "\a3\modules_f\data\iconTaskCreate_ca.paa"] call zen_custom_modules_fnc_register) then {
	systemChat "[Bishop] Failed to add Zeus module feature: Misc: Create Suicide Bomber";
};
*/

/*
if !([_m, "Misc: Managed Mortar Team", {
	_zen_pos    = _this select 0;
	_zen_target = _this select 1;
	if (_zen_target isKindOf "Man") exitWith {
		[_zen_target] execVM "functions\server\fnc_createManagedMortarTeam.sqf";
		hint "Created dynamic mortar team!";
	};
	hint "Invalid Target!";
	
}, "\a3\modules_f\data\iconTaskCreate_ca.paa"] call zen_custom_modules_fnc_register) then {
	systemChat "[Bishop] Failed to add Zeus module feature: Managed Mortar Team";
};
*/

// Icons: pbo: X:\Steam\steamapps\common\Arma 3\Addons\modules_f_data.pbo

if !([_m, "Dev: Adjust Funding", {
	if !(["Bishop: Global Intel",
		[
			[ // 0
				"EDIT:MULTI",
				["Adjust Funding", "Enter the amount to add, enter a negative integer to subtract funding. Scientific format or standard are supported."],
				[
					"1000000",
					{},
					6
				],
				false
			]
		],
		{
			// On Accept //
			try{
				private _amountstr = (_this select 0) select 0;
				private _amount    = parseNumber _amountstr;
				[_amount] remoteExec ["fnc_addToFunding", 2];
				private _opstring = "added to";
				private _sentimentclass = "IntelGreen";
				if ('-' in _amountstr) then {
					_opstring = "subtracted from";
					_sentimentclass = "IntelRed";
				};
				[_sentimentclass, [format["%1 was %2 funding!", [_amount] call fnc_standardNumericalNotationString, _opstring]]] remoteExec ["BIS_fnc_showNotification"];
			} catch {
				hint "Invalid Amount!";
			};
		},
		{hint "Bishop: Action Canceled"},
		[_this select 0, _this select 1]
	] call zen_dialog_fnc_create) then {hint "Bishop: Failed To Spawn!"};	
}, "\a3\modules_f\data\iconHQ_ca.paa"] call zen_custom_modules_fnc_register) then {
	systemChat "[Bishop] Failed to add Zeus module feature: Adjust Funding";
};