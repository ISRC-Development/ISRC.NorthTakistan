fnc_isMovable = {
	params["_object"];
	private _movable = false;
	if (_object getVariable ["isrc_engineer_movable", false]) then {
		_movable = true;
	};
	if (_object getVariable ["is_blufor_asset", false]) then {
		_movable = true;
	};
	if (_object getVariable ["is_prop", false]) then {
		_movable = true;
	};
	if (
		_object isKindOf "Car" 
		|| _object isKindOf "Tank" 
		|| _object isKindOf "Truck" 
		|| _object isKindOf "Air" 
		|| _object isKindOf "Ship"
		|| _object isKindOf "Turret"
		) then { 
		_movable = true;
	};
	_movable
};

fnc_updateMovable = {
	params["_object"];
	private _id = _object getVariable ["isrc_engineer_movable_id", false];
	if (typeName _id == "STRING") then {
		// [_id, _pos, _dir] call fnc_updatePersistentObject; 
		[_id, getPos _object, getDir _object] remoteExec ["fnc_updatePersistentObject", 2];
	};
};

ISRC_my_addactions set ["move_object", player addAction 
[
	"<t color='#FFFF00' font='PuristaBold'>[ENGINEER] Move Object</t>",	// title
	{
		params ["_target", "_caller", "_actionId", "_arguments"]; // script
		execVM "client\object_placement\object_manipulation_dialog.sqf";
	},
	nil,		// arguments
	1.0,		// priority
	false,		// showWindow
	false,		// hideOnUse
	"",			// shortcut
	"(cursorTarget distance2D player < 20 && [cursorTarget] call fnc_isMovable && typeName (cursorTarget getVariable ['isrc_engineer_movable', false]) == 'BOOL')", 	// condition
	50,			// radius
	false,		// unconscious
	"",			// selection
	""			// memoryPoint
]];	

ISRC_my_addactions set ["snap_object", player addAction 
[
	"<t color='#FFFF00' font='PuristaBold'>[ENGINEER] Snap To Terrain</t>",	// title
	{
		params ["_target", "_caller", "_actionId", "_arguments"]; // script
		private _curtarget = cursorTarget;
		_curtarget setVectorUp surfaceNormal position _curtarget;
	},
	nil,		// arguments
	1.0,		// priority
	false,		// showWindow
	false,		// hideOnUse
	"",			// shortcut
	"(cursorTarget distance2D player < 20 && [cursorTarget] call fnc_isMovable && typeName (cursorTarget getVariable ['isrc_engineer_movable', false]) == 'BOOL')", 	// condition
	50,			// radius
	false,		// unconscious
	"",			// selection
	""			// memoryPoint
]];	

ISRC_my_addactions set ["purchase_object", player addAction 
[
	"<t color='#00FF00' font='PuristaBold'>[ENGINEER] Purchase Materials</t>",	// title
	{
		params ["_target", "_caller", "_actionId", "_arguments"]; // script
		execVM "client\object_placement\objects_build_menu.sqf";
	},
	nil,		// arguments
	1.0,		// priority
	false,		// showWindow
	false,		// hideOnUse
	"",			// shortcut
	"(isNull objectParent player)", // condition - not in vehicle	
	50,			// radius
	false,		// unconscious
	"",			// selection
	""			// memoryPoint
]];	

ISRC_my_addactions set ["remove_object", player addAction 
[
	"<t color='#00FF00' font='PuristaBold'>[ENGINEER] Recycle Object</t>",	// title
	{
		params ["_target", "_caller", "_actionId", "_arguments"]; // script
		[ cursorTarget getVariable "isrc_engineer_movable_id" ] remoteExec ["fnc_removePersistentObject", 2];
	},
	nil,		// arguments
	1.0,		// priority
	false,		// showWindow
	false,		// hideOnUse
	"",			// shortcut
	"(isNull objectParent player && typeName (cursorTarget getVariable ['isrc_engineer_movable_id', false]) != 'BOOL' )", // condition - not in vehicle	& is movable w/ ID
	50,			// radius
	false,		// unconscious
	"",			// selection
	""			// memoryPoint
]];	

fnc_loadToFlatbed = {
	params["_object", "_vehicle"];
	_vehicle setVehicleCargo _object;

};

fnc_loadableToFlatbed = {
	// returns false or loadable vehicle object - 20m radius
	params["_target"];
	private _loadable = false;
	{
		if (typeOf _x == "B_T_Truck_01_flatbed_F" && (_x canVehicleCargo _target) select 0) then {
			_loadable = _x;
		};
	} forEach (nearestObjects [_target, [], 20]);
	_loadable
};

ISRC_my_addactions set ["load_object", player addAction 
[
	"<t color='#00FF00' font='PuristaBold'>[ENGINEER] Load To Flatbed</t>",	// title
	{
		params ["_target", "_caller", "_actionId", "_arguments"]; // script
		[cursorTarget, [cursorTarget] call fnc_loadableToFlatbed] call fnc_loadToFlatbed;
	},
	nil,		// arguments
	1.0,		// priority
	false,		// showWindow
	false,		// hideOnUse
	"",			// shortcut
	"(isNull objectParent player && typeName (cursorTarget getVariable ['isrc_engineer_movable', false]) == 'BOOL' && typeName ([cursorTarget] call fnc_loadableToFlatbed) != 'BOOL')", // condition - not in vehicle	& is movable w/ ID
	50,			// radius
	false,		// unconscious
	"",			// selection
	""			// memoryPoint
]];	

