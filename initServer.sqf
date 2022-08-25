ACTIVE_SECTORS = [];
call compileFinal preprocessFileLineNumbers "config\settings.sqf";
call compileFinal preprocessFileLineNumbers "config\weaponsAndCrates.sqf";
call compileFinal preprocessFileLineNumbers "server\crateManager.sqf";
call compileFinal preprocessFileLineNumbers "server\sector_manager.sqf";
call compileFinal preprocessFileLineNumbers "inits\server.sqf"; // Server inits
call compileFinal preprocessFileLineNumbers "inits\global.sqf"; // Global inits for mainly huron containers
call compileFinal preprocessFileLineNumbers "client\logistics.sqf"; // needed to get all crates
call compileFinal preprocessFileLineNumbers "headless_client\index.sqf";
call compileFinal preprocessFileLineNumbers "config\blufor_purchase_objects.sqf";

// Experiments // 
call compileFinal preprocessFileLineNumbers "client\experiments\electronic_warfare\server.sqf";
// End Experiments //

missionNamespace setVariable ["MANAGED_PURCHASED_VEHICLES", []];

// clean up the vehicle yard
{
    if ( !("EmptyDetector" in typeOf _x) && !("trigger" in typeOf _x) ) then {
        hideObjectGlobal _x;
    };
} forEach nearestTerrainObjects [VEHICLE_YARD_CENTER, [], VEHICLE_YARD_RADIUS];

fnc_HcOnline = {
    private _online = false;
    {
        if (typeOf _x == "HeadlessClient_F") then {
            _online = true;
        };
    } forEach allPlayers;
    _online
};

fnc_randomIdentity = {
	params[["_male", true], ["_range", 3]];
	private _class = "ISRC_CIV_IDENTITY_";
	if (_male) then {
		_class = _class + "MALE_" + str round (random _range);
	} else {
		_class = _class + "FEMALE_" + str round (random _range);
	};
	_class
};

/// TRANSFERS FROM INITSERVER.SQF FOR HCL SUPPORT
fnc_cleanVehicle = {
    params["_vehicle"];
    clearMagazineCargoGlobal _vehicle;
    clearItemCargoGlobal 	 _vehicle;
    clearBackpackCargoGlobal _vehicle;
    clearWeaponCargoGlobal 	 _vehicle;
};

fnc_marker = {
    params["_pos", ["_text", false], ["_color", "ColorGreen"], ["_type", "mil_dot"], ["_timestamp", false], ["_size", [1, 1]]];
    private _marker = createMarker [[6] call fnc_genId, _pos];
    _marker setMarkerType _type;
    _marker setMarkerColor _color;
    _marker setMarkerSize _size;
    if (typeName _text == "STRING") then {
        if (_timestamp) then {
            _marker setMarkerText format["%1 - %2", _text, [daytime] call BIS_fnc_timeToString];
        } else {
            _marker setMarkerText _text;
        }
    };
};

fnc_sum = {
    params["_array"];
    private _sum = 0;
    {_sum = _sum + _x} forEach _array;
    _sum
};

fnc_getPlayersMeanPos = {
    private _pos     = false;
	private _players = [];
	private _ppx     = [];
	private _ppy     = [];
	
	private _ppx_am  = 0;
	private _ppy_am  = 0;

	{
        if (typeOf _x != "HeadlessClient_F") then {
            _players pushBack _x;
            _ppx pushBack ((getPos _x) select 0);
            _ppy pushBack ((getPos _x) select 1);
	    }
    } forEach allPlayers;
	_ppx_am =  ([_ppx] call fnc_sum) / count _ppx;
	_ppy_am = ([_ppy] call fnc_sum) / count _ppy;

	if (count _players > 0) then {
        _pos = [_ppx_am, _ppy_am, 0];
    };

    _pos

};

fnc_getDisplyName = {
	params ["_classname"];
	[configFile >> "CfgVehicles" >> _classname] call BIS_fnc_displayName
};

fnc_standardNotation = {
    params["_int"];
    ((_int call BIS_fnc_numberText) splitString " ") joinString ","
};

fnc_getCurrentFundingBalance = {
    profileNamespace getVariable ["CURRENT_FUNDING_BALANCE", 0]
};

fnc_currentFundingStandard = {
    format["$%1", [call fnc_getCurrentFundingBalance] call fnc_standardNotation]
};

fnc_addToFunding = {
    params ["_amount"];
    private _newBalance = call fnc_getCurrentFundingBalance + _amount;
    profileNamespace setVariable ["CURRENT_FUNDING_BALANCE", _newBalance];
    missionNamespace setVariable ["CURRENT_FUNDING_BALANCE", _newBalance];
    saveprofilenamespace;
};

fnc_subtractFunding = {
    params ["_amount"];
    private _newBalance = call fnc_getCurrentFundingBalance - _amount;
    profileNamespace setVariable ["CURRENT_FUNDING_BALANCE", _newBalance];
    missionNamespace setVariable ["CURRENT_FUNDING_BALANCE", _newBalance];
    saveprofilenamespace;
};

fnc_setCivRating = {
    params ["_rating"];
    if (_rating > 100) then {_rating = 100};
    if (_rating < 0) then {_rating = 0};
    profileNamespace setVariable ["CIV_RATING", _rating];
    missionNamespace setVariable ["CIV_RATING", _rating];
    saveprofilenamespace;
};

fnc_getCivRating = {
    profileNamespace getVariable ["CIV_RATING", 0]
};

fnc_civRateAdd = {
    [((call fnc_getCivRating) + 1)] call fnc_setCivRating;
};

fnc_civRateSubtract = {
    [((call fnc_getCivRating) - 1)] call fnc_setCivRating;
};

fnc_addPersistentObject = {
    // [_object] call fnc_addPersistentObject;
    params ["_object"];
    private _id = [12] call fnc_genId;
    [_object, ["isrc_engineer_movable_id", _id]] remoteExec ["setVariable", 0, _object];
    private _serialized = [
        _id,
        typeOf _object,
        getPos _object,
        getDir _object
    ];
    profileNamespace setVariable ["PERSISTENT_OBJECTS", (profileNamespace getVariable ["PERSISTENT_OBJECTS", []]) + [_serialized] ];   
    saveprofilenamespace;
    //systemChat format["[SERVER] Persistent object %1 added -> %2", _id, profileNamespace getVariable ["PERSISTENT_OBJECTS", []]];
};

fnc_updatePersistentObject = {
    // [_id, _pos, _dir] call fnc_updatePersistentObject; 
    params ["_id", "_pos", "_dir"];
    private _replace = [];
    {
        private _new_array = [_id, _x select 1]; // id, type, ...
        if (_x select 0 == _id) then {
            if (typeName _pos != "BOOL") then {
                _new_array pushBack _pos;
            } else {
                _new_array pushBack (_x select 2);
            };
            if (typeName _dir != "BOOL") then {
                _new_array pushBack _dir;
            } else {
                _new_array pushBack (_x select 3);
            };
            _replace pushBack _new_array;
        } else {
            _replace pushBack _x;
        };
    } forEach (profileNamespace getVariable ["PERSISTENT_OBJECTS", []]);
    profileNamespace setVariable ["PERSISTENT_OBJECTS", _replace];
    saveprofilenamespace;
    true
};

fnc_persistentObjectsToClipboard = {
    if (isServer && hasInterface) then {
        copyToClipboard format["%1", profileNamespace getVariable ["PERSISTENT_OBJECTS", []]];
    };
};

fnc_getObjectPriceByClassName = {
    params ["_class"];
    private _price = 0;
    {
        {
            if (_x select 1 == _class) then {
                _price = _x select 2;
            };
        } forEach (_x select 1);
    } forEach ISRC_BUILDABLE_OBJECTS;
    _price
};

fnc_removePersistentObject = {
    // [_id] call fnc_removePersistentObject;
    params ["_id"];

    {
        if (_x getVariable ["isrc_engineer_movable_id", ""] == _id) then {
            deleteVehicle _x;
        };
    } forEach allMissionObjects "all";    

    private _replace = [];

    {
        if (_x select 0 != _id) then {
            _replace pushBack _x;
        } else {
            // reimburse
            [[_x select 1] call fnc_getObjectPriceByClassName] call fnc_addToFunding; 
        };
    } forEach (profileNamespace getVariable ["PERSISTENT_OBJECTS", []]);
    profileNamespace setVariable ["PERSISTENT_OBJECTS", _replace];
    saveprofilenamespace;
    true
};

fnc_initializeAllPersistentObjects = {
    private _replace = [];
    {
        if !(isNil "_x") then {
            private _id = _x select 0;
            private _type = _x select 1;
            private _pos = _x select 2;
            private _dir = _x select 3;
            private _veh = _type createVehicle _pos;
            _veh setDir _dir;
            [_veh, ["is_prop", true]] remoteExec ["setVariable", 0, _veh];
           
            [_veh, ["isrc_engineer_movable", true]] remoteExec ["setVariable", 0, _veh];
            _veh setVariable ["isrc_engineer_movable", true];
            [_veh, ["isrc_engineer_movable_id", _id]] remoteExec ["setVariable", 0, _veh];
            _veh setVariable ["isrc_engineer_movable_id", _id];
            [_veh, false] remoteExec ["allowDamage", 0, _veh];
            _veh allowDamage false;
            _veh enableSimulation false;
            _replace pushBack _x;
        } else {
            systemChat "Persistent object is null -> removing from profileNamespace...";
        };
    } forEach (profileNamespace getVariable ["PERSISTENT_OBJECTS", []]);
    profileNamespace setVariable ["PERSISTENT_OBJECTS", _replace ];   
    saveprofilenamespace;
};

fnc_clearPersistentObjects = {
    profileNamespace setVariable ["PERSISTENT_OBJECTS", []];
    saveprofilenamespace;
};

// Restart captured progress
if (DO_RESTART) then {

    // Set starting persistent objects
    profileNamespace setVariable ["PERSISTENT_OBJECTS", []];

    // Captured sectors
    profileNamespace setVariable ["CAPTURED_SECTORS", []];

    // Purchased Vehicles
    profileNamespace setVariable ["PURCHASED_VEHICLES", []];    

    // Set Civrating
    [STARTING_CIV_REP] call fnc_setCivRating;

    // Set starting funds
    profileNamespace setVariable ["CURRENT_FUNDING_BALANCE", STARTING_FUNDING];
    missionNamespace setVariable ["CURRENT_FUNDING_BALANCE", STARTING_FUNDING];

    // Todos
    profileNamespace setVariable ["VEHICLE_LOCATIONS", []];

    // COP_LOCATION
    profileNamespace setVariable ["COP_LOCATION", STARTING_COP_LOCATION];
    missionNamespace setVariable ["COP_LOCATION", STARTING_COP_LOCATION];
    
    saveprofilenamespace;
};

// Hotfix for persistent objects being added mid-progress
if (typeName (profileNamespace getVariable ["PERSISTENT_OBJECTS", false]) == "BOOL") then {
    profileNamespace setVariable ["PERSISTENT_OBJECTS", []];
    saveprofilenamespace;
};

// pass civrating from profile to mission namespace
missionNamespace setVariable ["CIV_RATING", call fnc_getCivRating];

// Set starting funds
missionNamespace setVariable ["CURRENT_FUNDING_BALANCE", call fnc_getCurrentFundingBalance];

// pass cop_location from profile to mission namespace
missionNamespace setVariable ["COP_LOCATION", profileNamespace getVariable ["COP_LOCATION", false]];

fnc_getCopLocation = {
    profileNamespace getVariable ["COP_LOCATION", [0,0,0]]
};

fnc_setCopLocation = {
    params ["_location"];
    profileNamespace setVariable ["COP_LOCATION", _location];
    missionNamespace setVariable ["COP_LOCATION", _location];
    saveprofilenamespace;
};

fnc_genId = {
    params["_length"];
    private _str = "";
    private _rnd = ["A", "B", "C", "D", "E", "F"];    
    for "_i" from 0 to _length do{
        _str = _str + (selectRandom _rnd);
    };
    _str
};

/* Asset Markers */
fnc_updateVehicleMarkers = {
    {
        if (["asset_marker_", _x] call BIS_fnc_inString) then {
            deleteMarker _x;
        };
    } forEach allMapMarkers;
    {        
        if (
            (
                (_x getVariable["is_blufor_asset", false] == true) 
                || (_x getVariable["is_purchased_asset", false] == true)
                || (_x getVariable["isrc_engineer_movable", false] == true)
            ) && (
                count crew _x == 0
                )
        ) then {
            private _markerId = format["asset_marker_%1", [12] call fnc_genId];
            private _displayName = getText (configFile >> "CfgVehicles" >> (typeOf _x) >> "displayName");
            private _marker = createMarker [_markerId, getPos _x];
            private _markerColor = "ColorKhaki";
            if (_x getVariable["isrc_engineer_movable", false] == true) then {
                _displayName = _displayName + " [Movable]";
                _markerColor = "colorCivilian";
                _marker setMarkerAlpha 0.5; 
            };

            _marker setMarkerColor _markerColor;
            _marker setMarkerType "mil_dot";
            _marker setMarkerSize [0.5, 0.5];
            _marker setMarkerText _displayName;
        };
    } forEach allMissionObjects "";
};

fnc_getPlayersMeanPos = {
    private _px = []; private _py = []; private _pz = [];
    {
        private _pos = getPos _x;
        _px pushBack (_pos select 0);
        _py pushBack (_pos select 1);
    } forEach allPlayers;
    private _out = [
        _px call BIS_fnc_arithmeticMean,
        _py call BIS_fnc_arithmeticMean,
        0
    ]; 
    if (count allPlayers == 0) then {
        _out = [];
    };
    _out
};

fnc_globalChat = {
	params["_message"];
	_message remoteExec ["systemChat"];		
};

fnc_globalHint = {
	params["_message"];
	_message remoteExec ["hint"];		
};

// Get random safe pos
fnc_randPos = {
    params ["_center", "_radius"];
    // random pos 
    private _rp        = [[[_center, _radius]], []] call BIS_fnc_randomPos;
    // safe position
	private _sp        = [_rp, 3, 500, 3, 0, 20, 0] call BIS_fnc_findSafePos;
    
    _sp
};

fnc_inCleanupWhitelistArea = {
    // https://community.bistudio.com/wiki/inArea#:~:text=position%20inArea%20%5Bcenter%2C%20a%2C%20b%2C%20angle%2C%20isRectangle%2C%20c%5D
    params ["_pos"];
    private _in = false;
    {
        if (_pos inArea _x) then {
            _in = true;
        };
    } forEach CLEANUP_WHITELIST_AREAS;
    _in
};

fnc_postProcessVehicle = {
    params ["_vehicle"];
    switch (typeOf _vehicle) do {
        case "USAF_MQ9": {
            createVehicleCrew _vehicle;
        };
        case "ITC_Land_B_UAV_AR2i": {
            createVehicleCrew _vehicle;
        };
        default { };
    };
};

fnc_setAssetRespawn_new = {
        params ["_asset"];

        private _respawnpos = _asset getVariable["respawn_location", [0, 0, 0]];
        
        [_asset, _respawnpos] spawn {
            params ["_asset", "_respawnpos"];

            private _type = typeOf _asset;
            
            while {alive _asset} do {
                sleep 1;
            };

            [format ["Asset %1 was destroyed! It will respawn at the vehicle yard in 15 minutes.", [_type] call fnc_getDisplyName]] call fnc_globalChat;

            sleep 900; // 10 = testing // 900 = default

            // Just added, needs testing...
            private _safepos       = [VEHICLE_YARD_CENTER, 1, VEHICLE_YARD_RADIUS, 2, 0, 30, 0] call BIS_fnc_findSafePos;

            private _vehicle       = _type createVehicle _safepos;
            [_vehicle] call fnc_postProcessVehicle;
            [_vehicle] call fnc_cleanVehicle;
            _vehicle setVectorUp surfaceNormal (getposATL _vehicle);	
            _vehicle setVariable["is_blufor_asset", true, true];
            _vehicle setVariable["respawn_location", _respawnpos, true];  
            [_vehicle] execVM "functions\global\fnc_initAssetAppearance.sqf";  
            [_vehicle] call fnc_setAssetRespawn_new;
            [ format ["%1 has respawned at the vehicle yard.", [_type] call fnc_getDisplyName] ] call fnc_globalChat;
        };
};

fnc_getAllWhitelist = {
    private _whitelist = ISRC_static_weapons; // Whitelist static weapons
    {_whitelist pushBack (_x select 1)} forEach ISRC_supply_crates; // Whitelist supply crates
    _whitelist;
};

[] spawn
{
    // Establish respawn loop for our vics
    // Just add :
    /*
    this setVariable["is_blufor_asset", true];
    this setVariable["respawn_location", getPos this];
    */
    // to the init of the vehicle.
    {
        if (_x getVariable ["is_blufor_asset", false] == true) then {
            _x setVariable["respawn_location", getPos _x, true];
            [_x] call fnc_setAssetRespawn_new;
        };
    } forEach allMissionObjects "";
};

// Cleanup Script
[] spawn 
{
    while {true} do // looping
    {
        //systemChat format["[DEBUG] %1 vehicles",  count vehicles];
        ["[WARNING] Executing cleanup in 60 seconds!"] call fnc_globalChat;
        sleep 60;
        {
            //private _isblacklisted = [ getPos _x, [651, 1701] ] call BIS_fnc_isPosBlacklisted;
            if ( 
                (_x getVariable ["is_blufor_asset", false] == false) 
                && (_x getVariable ["is_prop", false] == false) 
                && (count (crew _x) == 0)
                && !((typeOf _x) in ([] call fnc_getAllWhitelist))
                && !("ACE_IR_Strobe" in typeOf _x)
                && !("ace_refuel" in typeOf _x)
                && !("Rope" in typeOf _x)
                && !("WeaponHolderSimulated" in typeOf _x)
                && !("LaserTargetW" in typeOf _x)
                && !([getPos _x] call fnc_inCleanupWhitelistArea)
                ) then {
                    //systemChat format ["[DEBUG] Cleaning up %1", typeOf _x];
                    deleteVehicle _x;
            };
        } forEach vehicles;

        { deleteVehicle _x } forEach allDeadMen;
        { deleteVehicle _x } forEach allDead;

        //systemChat format["[DEBUG] %1 vehicles [AFTER]",  count vehicles];
        sleep (CLEANUP_INTERVAL - 60);
        {
            // Fuel-up all non-blufor motorists
            if ((side _x != WEST) && !(isNull objectParent _x)) then {
                (vehicle _x) setFuel 1;
                //(vehicle _x) setDamage 0;
            };         
        } forEach allUnits;
    };
};

_server_fps_marker = createMarker ["server_fps_marker", [0, 1400, 0]];
_server_fps_marker setMarkerColor "ColorWhite";
_server_fps_marker setMarkerType "loc_Box";

_server_units_marker = createMarker ["server_units_marker", [0, 1200, 0]];
_server_units_marker setMarkerColor "ColorGreen";
_server_units_marker setMarkerType "loc_download";

// This is a band-aid fix for a bug: randomly getting kicked from zeus.
// Also refuels civi/opfor vehicles.
// Also sets non-blufor conciousness to false
// Also manages asset markers
// Also tracks player count
[_server_fps_marker, _server_units_marker] spawn {
    params["_server_units_marker", "_server_fps_marker"];
    while {true} do{

        // Asset Markers
        [] call fnc_updateVehicleMarkers;   

        // FPS Marker Update
        private _fps = diag_fps;
        if (_fps >= 20) then {
            _server_fps_marker setMarkerColor "ColorGreen";
        } else {
            if (_fps >= 10) then {
                _server_fps_marker setMarkerColor "ColorYellow";
            } else {
                _server_fps_marker setMarkerColor "ColorRed";
            }
        };
        _server_fps_marker setMarkerText format["Server FPS: %1", floor(_fps / 1)];    

        // Server Units Marker Update
        private _units = 0;
        {if (local _x) then {_units = _units + 1}} forEach allUnits;
        _server_units_marker setMarkerText format["Server Units: %1", _units];

        sleep ISRC_MARKER_UPDATE_INTERVAL;
    };
};

//////////////////// Dynamic Sectors

fnc_getMapRadius    = {
    private _map_size = [(getArray (configfile >> "CfgWorlds" >> worldName >> "centerPosition")), 2] call BIS_fnc_vectorMultiply;
	if ((_map_size select 0) < (_map_size select 1)) then {(_map_size select 0)} else {(_map_size select 1)}
};

fnc_sector_isSectorActive = {
    params["_sector_name"];
    private _location = [_sector_name] call fnc_getLocationByName;
    if (isNil "_location") then {
        hint format["fnc_sector_isSectorActive('%1') -> Error: Sector not found", _sector_name];
    };
    if ((_location select 3) in ([] call fnc_sector_getActiveSectors)) then {true} else {false}
};

fnc_getServerPop    = {
    _bf = 0;
    _of = 0;
    _re = 0;
    _ci = 0;
    _pl = 0; // Seperate
    {
        switch (side _x) do {
            case west: {
                _bf = _bf + 1;
            };
            case east: {
                _of = _of + 1;
            };
            case resistance: {
                _re = _re + 1;
            };
            case civilian: {
                _ci = _ci + 1;
            };
            default {};
        };        
    } forEach allUnits;
    [_bf, _of, _re, _ci, count allPlayers] call fnc_getServerPop
};

fnc_triggerId = {
    params["_trigger"];
    private _uid = _trigger getVariable['LOCATION_ID', false];
    _uid
};

fnc_civilian_getMotoristPopulation = {
    _population = 0;
    {
        if ((side _x == civilian) && !(isNull objectParent _x)) then {
            _population = _population + 1;
        };
    } forEach allUnits;
    _population
};

fnc_civilian_getPedestrianPopulation = {
    _population = 0;
    {
        if ((side _x == civilian) && (isNull objectParent _x)) then {
            _population = _population + 1;
        };
    } forEach allUnits;
    _population
};

fnc_randPosSafe = {
    params ["_center", "_radius"];
    private _rp        = [[[_center, _radius]], []] call BIS_fnc_randomPos;
	private _sp        = [_rp, 3, 150, 5, 0, 20, 0] call BIS_fnc_findSafePos;
    _sp
};

fnc_groupHasVehicle = {
    params["_group"];
    {
        if (count typeOf(assignedVehicle player) > 0) exitWith {true};
    } forEach units _group;
    false
};

fnc_groupMeanPosition = { // Broken-ass fucked up shit.
    params["_group"];
    private _px = []; private _py = []; private _pz = [];
    {
        private _pos = getPos _x;
        _px pushBack (_pos select 0);
        _py pushBack (_pos select 1);
    } forEach units _group;
    private _out = [
        _px call BIS_fnc_arithmeticMean,
        _py call BIS_fnc_arithmeticMean,
        0
    ]; 
    // Stupid ass fucked up typing in SQF, fuck SCALAR and fuck SCALAR NaN, there's no damned difference, fuuuuuuuuck this shit.
    _out
};

fnc_server_setVar = {
    params["_var", "_value"];
    profileNameSpace setVariable [_var, _value];
    saveprofilenamespace;
    missionNameSpace setVariable [_var, _value, true];
};

fnc_getNameFromTrigger = {
    params["_trigger"];
    private _meta = _trigger getVariable['LOCATION_META', ["N/A"]];
    (_meta select 0)
};

FD_fnc_bluforPopInTriggerArea = {
    params["_trigger"];
    private _bfcount = 0;
    {
        if (side _x == west) then {
            if (_x inArea _trigger && _x isKindOf "Man") then {
                _bfcount = _bfcount + 1;
            };            
        };
    } forEach allUnits;
    _bfcount
};

fnc_setRandomIdentity = {
    params["_unit", ["_male", true], ["_range", 20]];
    private _id = [_male, _range] call fnc_randomIdentity; // *3 max and female only currently!!!!*
    _unit setIdentity _id;
};

fnc_establishTransmitter = {
    private _name   = _this select 0;
    private _pos    = _this select 1;
    private _type   = _this select 2;

    // clean up the area - 100m radius
    {
        if ( !("EmptyDetector" in typeOf _x) && !("trigger" in typeOf _x) ) then {
            hideObjectGlobal _x;
        };
    } forEach nearestTerrainObjects [_pos, [], 100];

    {
        if ( !("EmptyDetector" in typeOf _x) && !("trigger" in typeOf _x) ) then {
            hideObjectGlobal _x;
        };
    } forEach nearestObjects [_pos, [], 100];

    // Create the transmitter marker
    //private _m = createMarker [format["RadioTower_test_", hashValue _name], _pos];
    //_m setMarkerType "loc_Transmitter";
    //_m setMarkerSize [1, 1];

    [_pos] execVM "compositions\radio_tower_1.sqf";

    [_pos] spawn {
        params["_pos"];
        sleep 15;
        {
            _x setVectorUp [0, 0, 1];
            if ("fence" in typeOf _x || "barrier" in typeOf _x) then {
                _x enableSimulationGlobal false;
            };
        } forEach nearestObjects [_pos, [], 150];   
    };
};

// Set CAPTURED_SECTORS as [] if not yet set
if (typeName (profileNamespace getVariable ["CAPTURED_SECTORS", false]) != "ARRAY") then {
    profileNamespace setVariable ["CAPTURED_SECTORS", []];
    saveprofilenamespace;
};

{
    // name
    // position
    // type
    // radius
    private _name   = _x select 0;
    private _pos    = _x select 1;
    private _type   = _x select 2;
    private _radius = _x select 3;


    if ("Radio Tower" in _name) then {
        [_name, _pos, _type] call fnc_establishTransmitter;
    };    


    private _location = createLocation [
        _name,
        _pos,
        _radius select 0,
        _radius select 1
    ];
    
    _location setText _name;
    _location setType _type;
    _location setName _name;

    _location setVariable ["IS_PROP", true];
} forEach USER_DEFINED_SECTORS;

LOCATIONS_BLACKLIST = [
    "Skalisty Island",
    "Skalisty Proliv"
];

fnc_getAllLocations = {
    // Returns -> [["Name", [x, y, z], "type"], ...]   
    private _placesCfg = configFile >> "CfgWorlds" >> worldName >> "Names";
    private _places = [];
    for "_i" from 0 to (count _placesCfg)-1 do
    {
        private _place    = _placesCfg select _i;
        private _name     = getText(_place >> "name");
        if (count _name < 1) then {
            systemChat format["[WARNING] No name found for %1", _place];
        };
        private _position = getArray (_place >> "position");
        private _type     = getText(_place >> "type");
        private _uid      = hashValue _name;

        if (!("Name" in _name) && !(_name in LOCATIONS_BLACKLIST)) then { // workaround for Weird thing where random stuff titled "NameLocal" etc pops up as a sector.
            _places set [_i, [_name, _position, _type, _uid, false, []]];
                             //name, position, type, uid, isActive, args
        };

    };
    {
        private _name     = _x select 0;
        private _position = _x select 1;
        private _type     = _x select 2;
        private _radius   = _x select 3;

        _places pushBack [
            _name,
            _position,
            _type,
            hashValue _name,
            false, 
            []
        ];
    } forEach USER_DEFINED_SECTORS;
    _places
};

fnc_getLocationByName = {
    params["_name"];
    systemChat format ["[DEBUG] Searching for location %1", _name];
    private _location = false;
    {
        if !(isNil "_x") then {
            private _loc_name = _x select 0;
            if (_loc_name == _name) then {
                _location = _x;
            };
        };
    } forEach (call fnc_getAllLocations);
    _location
};

LOG_TEST = "";

fnc_establishSector = {
    params["_v"];

    private _name   = _v select 0;
    private _pos    = _v select 1;
    private _type   = _v select 2;

    // Delete old marker if it exists
    //deleteMarker ("marker_" + (hashValue _name));

    // If location type not in desired location types array then continue unless debugging
    //if (!(_type in LOCATION_TYPES) && !(DEBUG)) then {continue};
    if (!(_type in LOCATION_TYPES)) then {continue};

    private _uid    = _v select 3;
    private _marker = "marker_" + _uid;

    private _radiusInfantry      = 250;
    private _radiusVehicles      = 400;
    private _radiusAir           = 600;
    private _radiusArmor         = 500;

    private _infantryCountRange  = [8, 10];
    private _vehiclesCountRange  = [3, 6];
    private _airCountRange       = [1, 2];
    private _armorCountRange     = [1, 3];

    //_markerColor         = "ColorYellow";  
    _markerType          = "o_unknown";   
    
    switch (_type) do {
        case "NameMarine": {
            _radiusInfantry      = 250;
            _radiusVehicles      = 1200; // extra large radius for marine vehicles
            _radiusAir           = 600;
            _radiusArmor         = 500;

            _infantryCountRange  = [0, 0];
            _vehiclesCountRange  = [5, 8];
            _airCountRange       = [0, 0];
            _armorCountRange     = [0, 0];

            //_markerColor         = "ColorYellow";  
            _markerType          = "o_naval";          
        };  
        case "RadioTower": {
            _radiusInfantry      = 300;
            _radiusVehicles      = 500;
            _radiusAir           = 800;
            _radiusArmor         = 600;

            _infantryCountRange  = [10, 15];
            _vehiclesCountRange  = [4, 8];
            _airCountRange       = [1, 2];
            _armorCountRange     = [1, 3];

            //_markerColor         = "ColorYellow";  
            _markerType          = "o_installation";          
        };                        
        case "NameLocal": {
            _radiusInfantry      = 300;
            _radiusVehicles      = 500;
            _radiusAir           = 800;
            _radiusArmor         = 600;

            _infantryCountRange  = [10, 15];
            _vehiclesCountRange  = [4, 8];
            _airCountRange       = [1, 2];
            _armorCountRange     = [1, 3];

            //_markerColor         = "ColorYellow";  
            _markerType          = "o_support";          
        };        
        case "NameVillage": {
            _radiusInfantry      = 350;
            _radiusVehicles      = 500;
            _radiusAir           = 800;
            _radiusArmor         = 600;

            _infantryCountRange  = [9, 15];
            _vehiclesCountRange  = [2, 8];
            _airCountRange       = [0, 3];
            _armorCountRange     = [1, 3];

            //_markerColor         = "ColorGreen"; 
            _markerType          = "o_unknown";           
        };
        case "NameCity": {
            _radiusInfantry      = 500;
            _radiusVehicles      = 1000;
            _radiusAir           = 1500;
            _radiusArmor         = 1000;

            _infantryCountRange  = [14, 18];
            _vehiclesCountRange  = [6, 10];
            _airCountRange       = [2, 4];
            _armorCountRange     = [6, 8];

            //_markerColor         = "ColorBlue";
            _markerType          = "o_unknown";
        };
        case "NameCityCapital": {
            _radiusInfantry      = 650;
            _radiusVehicles      = 800;
            _radiusAir           = 1000;
            _radiusArmor         = 850;

            _infantryCountRange  = [16, 20];
            _vehiclesCountRange  = [8, 12];
            _airCountRange       = [3, 6];
            _armorCountRange     = [6, 8];

            //_markerColor         = "ColorRed";
            _markerType          = "o_unknown";
        };
        default {};
    };

    createMarker [_marker, _pos];
    _marker setMarkerType _markerType;
    _marker setMarkerText _name;
    _marker setMarkerSize [0.6, 0.6];  
    _marker setMarkerColor "ColorBlue"; 

    // Get mean of radius'
    private _meanRad = [_radiusInfantry, _radiusVehicles, _radiusAir,  _radiusArmor] call BIS_fnc_geometricMean;

    // Create Sector if not already captured
    if ( !(_name in (profileNamespace getVariable ["CAPTURED_SECTORS", []])) && !(_name in ALREADY_CAPTURED) ) then {
        
        _marker setMarkerColor "ColorRed";

        private _trigger = createTrigger ["EmptyDetector", _pos, true];
        _trigger setTriggerArea [_meanRad, _meanRad, 0, false];
        _trigger setTriggerActivation ["WEST", "PRESENT", true];
        _trigger setTriggerStatements [
            "this && ([thisTrigger] call FD_fnc_bluforPopInTriggerArea >= BLUFOR_ACTIVATION_COUNT) && (MAX_ACTIVE_SECTORS > count(ACTIVE_SECTORS)) && !(([thisTrigger] call fnc_getNameFromTrigger) in ACTIVE_SECTORS)",
            "
            [thisTrigger] spawn {
                params['_trigger'];
                [_trigger] execVM 'functions\server\fnc_spawner.sqf';
            };
            ",
            ""
            ];
        
        // Stash location ID into the trigger's variables
        _trigger setVariable ["LOCATION_ID", _uid, true];
        
        //[_trigger, ["LOCATION_ID", _uid]] remoteExec ["setVariable", -2, _trigger]; // rexec and JIP the variable to the trigger

        _trigger setVariable ["LOCATION_META", [
            _name,
            _pos,
            _type,
            _uid,
            _marker,
            _radiusInfantry,
            _radiusVehicles,
            _radiusAir,
            _radiusArmor,
            _infantryCountRange,
            _vehiclesCountRange,
            _airCountRange,
            _armorCountRange
        ], true];

/*
       [_trigger, ["LOCATION_META", [
            _name,
            _pos,
            _type,
            _uid,
            _marker,
            _radiusInfantry,
            _radiusVehicles,
            _radiusAir,
            _radiusArmor,
            _infantryCountRange,
            _vehiclesCountRange,
            _airCountRange,
            _armorCountRange
        ]]] remoteExec ["setVariable", -2, _trigger]; // rexec and JIP the variable to the trigger
*/
        
    } else {
        // Captured Sector - occupational forces: IEDS
        if (_type in ["NameVillage", "NameCity", "NameCityCapital"]) then {
            private _civ_rating_coefficient = 100 - (profileNamespace getVariable ["CIV_RATING", 0]);
            if (_civ_rating_coefficient > 20) then {
                _civ_rating_coefficient = selectRandom[1, 2, 2];
                if (_civ_rating_coefficient > 50) then {
                    _civ_rating_coefficient = selectRandom[3, 4, 4];
                };
                if (_civ_rating_coefficient > 80) then {
                    _civ_rating_coefficient = selectRandom[10, 15, 20];
                };                
                for "_i" from 0 to (_civ_rating_coefficient) do {
                    
                    private _randomPos = [_pos, 1, 500, 1, 0, 25, 0, [], []] call BIS_fnc_findSafePos;
                    private _road   = [_randomPos, 800] call BIS_fnc_nearestRoad;
                    private _lstpos = _road getPos [7, random (360)];

                    private _class = selectRandom ["IEDLandBig_F","IEDLandSmall_F","IEDUrbanBig_F","IEDUrbanSmall_F"];
                    [_class, _lstpos] execVM "functions\server\fnc_createNetworkIED.sqf";

                    if (DEBUG) then {
                        private _marker = createMarker [format["ied_%1", [12] call fnc_genId], _road];
                        _marker setMarkerColor "ColorGreen";
                        _marker setMarkerType "mil_dot";
                    };
                };
            };
        };
        // Captured Sector - occupational forces: NameLocal aka "Factories" // disabled for now
        /*
        if ( _type in ["NameLocal"] && !("Radio Tower" in _name) ) then {
            for "_i" from 0 to selectRandom[0, 0, 1, 1, 2, 3] do {
                private _supply = (selectRandom (call fnc_getAllSuppllyClasses)) createVehicle ([[[_pos, 150]], []] call BIS_fnc_randomPos);
                _supply setVectorUp surfaceNormal (getposATL _supply);
                _supply allowDamage false;
                _supply setVariable ["IS_PROP", true];
                [_supply] call fnc_cleanVehicle;
            };            
        };
        */
    };
    _marker setMarkerAlpha 1;
};

// Establish Map-Defined Sectors
{
    if !(isNil "_x") then {
        [_x] call fnc_establishSector;
    };
} forEach ([] call fnc_getAllLocations); 

if ( typeName (call fnc_getCopLocation) != "BOOL") then {
    [call fnc_getCopLocation, true] execVM "functions\server\fnc_spawnCOP.sqf";
};

private _marker = createMarker ["fob_marker", RESPAWN_LOCATION]; // Not visible yet.
_marker setMarkerType "hd_flag"; // Visible.
_marker setMarkerColor "ColorYellow"; // Blue.
_marker setMarkerText "FOB Alpha"; // Text.

if !(FOB_BRAVO_LOCATION isEqualTo [0, 0, 0]) then {
    private _bravo_marker = createMarker ["fob_bravo_marker", FOB_BRAVO_LOCATION]; // Not visible yet.
    _bravo_marker setMarkerType "hd_flag"; // Visible.
    _bravo_marker setMarkerColor "ColorYellow"; // Blue.
    _bravo_marker setMarkerText "FOB Bravo"; // Text.    
};

if !(FOB_CHARLIE_LOCATION isEqualTo [0, 0, 0]) then {
    private _bravo_marker = createMarker ["fob_charlie_marker", FOB_CHARLIE_LOCATION]; // Not visible yet.
    _bravo_marker setMarkerType "hd_flag"; // Visible.
    _bravo_marker setMarkerColor "ColorYellow"; // Blue.
    _bravo_marker setMarkerText "FOB Charlie"; // Text.    
};

/*
addMissionEventHandler ["BuildingChanged", {
	params ["_from", "_to", "_isRuin"];
    if (_isRuin) then {
        call fnc_civRateSubtract;
    }; // todo: allow players to rebuild houses
}];
*/

/*
addMissionEventHandler ["HandleDisconnect", {
	params ["_unit", "_id", "_uid", "_name"];
    deleteVehicle _unit;
	true;
}]; 
systemChat format["[SERVER] Handling disconnects"];
*/

fnc_processPurchasedVehicle = {
    params["_vehicle"];
    _vehicle setVariable ["IS_PROP", true, true];
    _vehicle setVariable ["is_purchased_asset", true, true];
};

fnc_getEnemySector = {
    params [["_getcapturedsector", false]];
    private _deployment = false;
    private _safeCheck  = 0;
    if !(_getcapturedsector) then {
        while {typeName _deployment == "BOOL"} do {
            private _location = selectRandom (call fnc_getAllLocations);
            private _name     = _location select 0;
            if (!(_name in (profileNamespace getVariable ["CAPTURED_SECTORS", []])) && (_location select 2) != "NameMarine") then {
                _deployment = _location;
            };
            _safeCheck = _safeCheck + 1;
            if (_safeCheck > 1024) then {
                _deployment = false;
            };
        };        
    } else {
        while {typeName _deployment == "BOOL"} do {
            private _location = selectRandom (call fnc_getAllLocations);
            private _name     = _location select 0;
            if (_name in (profileNamespace getVariable ["CAPTURED_SECTORS", []]) && (_location select 2) != "NameMarine") then {
                _deployment = _location;
            };
            _safeCheck = _safeCheck + 1;
            if (_safeCheck > 1024) then {
                _deployment = false;
            };
        };       
    };
    _deployment
};

[] spawn {

    // sleep 1 hour
    sleep 350;

    // Give +1 civrep
    call fnc_civRateAdd;

    ["IntelGreen", ["+1 Reputation:<br/>Time Spent"]] remoteExec ["BIS_fnc_showNotification"];

    sleep (selectRandom [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]);

    // Give some funding based on civrep
    private _fundingCivRepCooefficient = (CIV_RATING * 0.10) * 100000;
    
    [_fundingCivRepCooefficient] call fnc_addToFunding;
    ["IntelGreen", [
        format["Daily Funding: <br/>$%1", [_fundingCivRepCooefficient] call fnc_standardNotation]
    ]] remoteExec ["BIS_fnc_showNotification"];

    sleep (selectRandom [3600, 3600, 3000, 3000, 2500, 2800]);
    //["create_battlegroup", []] call fnc_new_HC_job;

};
systemChat "[SERVER] Started bonus rewards loop";

[] spawn {
    while {true} do {

        // Arty controller
        if (count allPlayers == 0) then {continue}; // ignore if no players are online

        {
            
            if (leader _x getVariable ["is_mortarman", false]) then {

                private _mortarman = gunner vehicle leader _x;

                private _range = 1500;

                private _round = "8Rnd_82mm_Mo_shells";

                private _amount = 1;//floor(random(8));

                private _offset = floor(random 350);

                //systemChat format["[SERVER] Mortarman: %1", _mortarman];

                if (typeOf vehicle _mortarman == "RHS_BM21_VDV_01") then {
                    _range = 10000;
                    _round = "rhs_mag_m21of_1";
                    //_amount = 1;
                    _offset = floor(random 800);
                };

                if (typeOf vehicle _mortarman == "rhs_2s3_tv") then {
                    _range = 20000;
                    _round = "";
                    //_amount = 1;
                    _offset = floor(random 800);
                };

                private _enemies = (getPos _mortarman nearEntities [["Man", "Car", "Motorcycle", "Tank", "Turret"], _range]) select {side _x == west || RESISTANCE_IS_FRIENDLY && side _x == RESISTANCE}; // IGNORE AIR FOR MORTAR TEAMS
                
                if (count _enemies == 0) exitWith {};

                private _artyTarget = selectRandom _enemies;

                if (_artyTarget distance2D RESPAWN_LOCATION <= ARTY_CONTROLLER_FOB_BLACKLIST_RANGE || _artyTarget distance2D FOB_BRAVO_LOCATION <= ARTY_CONTROLLER_FOB_BLACKLIST_RANGE || _artyTarget distance2D FOB_CHARLIE_LOCATION <= ARTY_CONTROLLER_FOB_BLACKLIST_RANGE) then {
                    continue;
                };

                for "_i" from 0 to _amount do {
                    private _randpos = [[[getPos _artyTarget, _offset]], []] call BIS_fnc_randomPos; 
                    _mortarman doArtilleryFire [_randpos, _round, 1];
                }; 

            };

        } forEach allGroups select {side leader _x == ENEMY_SIDE || !RESISTANCE_IS_FRIENDLY && side leader _x == RESISTANCE};

        sleep selectRandom[80, 100, 120, 150, 180, 200];        
    };
};

fnc_removeOne = {
    params ["_array", "_remove"];
    private _found = false;
    private _new_array = [];
    {
        if !(_x isEqualTo _remove) then {
            _new_array pushBack _x;
        } else {
            if (!_found) then {
                _found = true;
            } else {
                _new_array pushBack _x;
            };
        };
    } forEach _array;
};

{
    if (typeName _x == "STRING") then {
        private _vehicle = _x createVehicle ([VEHICLE_YARD_CENTER, 1, VEHICLE_YARD_RADIUS, 2, 0, 30, 0] call BIS_fnc_findSafePos);
        [_vehicle] call fnc_cleanVehicle;
        [_vehicle] call fnc_processPurchasedVehicle; 
        MANAGED_PURCHASED_VEHICLES pushBack _vehicle;
        [_vehicle] execVM "functions\global\fnc_initAssetAppearance.sqf";  
    };
} forEach (profileNamespace getVariable ["PURCHASED_VEHICLES", []]);

// Watch vehicles
[] spawn {
    while {true} do {
        {
            if !(alive _x) then {
                private _vehicle = _x;
                private _pvs = profileNamespace getVariable ["PURCHASED_VEHICLES", []];
                _pvs deleteAt (_pvs findIf {_x == typeOf _vehicle});
                profileNamespace setVariable ["PURCHASED_VEHICLES", _pvs];
                saveProfileNamespace;
                MANAGED_PURCHASED_VEHICLES = MANAGED_PURCHASED_VEHICLES - [_x];             
            };
        } forEach MANAGED_PURCHASED_VEHICLES; 
        sleep 25;
    };
};

fnc_purchaseVehicle = {
    params["_vehicle"];
    private _currentPurchased = profileNamespace getVariable ["PURCHASED_VEHICLES", []];
    private _new = _currentPurchased + [typeOf _vehicle];
    profileNamespace setVariable ["PURCHASED_VEHICLES", _new];
    MANAGED_PURCHASED_VEHICLES pushBack _vehicle;
    [_vehicle] call fnc_processPurchasedVehicle;
    saveProfileNamespace;
};

HUMANITARIAN_RUNNING = false;
publicVariable "HUMANITARIAN_RUNNING";

0 setFog 0;
forceWeatherChange; 

// Create SAM sites
[] spawn {
	//while {true} do {
        
        sleep 1500;

        private _deployment = false;
        while {typeName _deployment == "BOOL"} do {
            private _location = selectRandom (call fnc_getAllLocations);;
            private _name     = _location select 0;
            if !(_name in (profileNamespace getVariable ["CAPTURED_SECTORS", []]) && (_location select 2) != "NameMarine") then {
                _deployment = _location;
            };
        };

        private _sstype = selectRandom ISRC_SAM_SITE;

        // Pancir 
        if ("min_rf_sa_22" in _sstype) then {
            private _ppos = [_deployment select 1, 1, selectRandom[250, 300, 500], 5, 0, 25, 0, [], []] call BIS_fnc_findSafePos;
            ["spawn_crewed_vehicle", [
                "min_rf_sa_22",
                _ppos,
                true,
                []
            ]] call fnc_new_HC_job;	
            [_ppos, "Unknown AA", "ColorBlack", "mil_warning", true, [0.5, 0.5]] call fnc_marker;
        };

        // S-750 Rhea SAM/Radar/Net
        if ("sam_site" in _sstype) then {
            [_deployment select 1] execVM "functions\server\fnc_build_sam_site.sqf";       
            [_deployment select 1, "SAM Site", "ColorBlack", "mil_warning", true, [0.5, 0.5]] call fnc_marker;     
        };

        // BM-21 Arty
        if (_sstype == "RHS_BM21_VDV_01") then {
            [_deployment select 1] execVM "functions\server\fnc_buildBatterySite.sqf";
            [_deployment select 1, "Battery", "ColorBlack", "mil_warning", true, [0.5, 0.5]] call fnc_marker;
        };

        // rhs_2s3_tv - arty
        if (_sstype == "rhs_2s3_tv") then {
            [_deployment select 1, "rhs_2s3_tv"] execVM "functions\server\fnc_buildBatterySite.sqf";
            [_deployment select 1, "Artillery", "ColorBlack", "mil_warning", true, [0.5, 0.5]] call fnc_marker;
        };

        if (DEBUG) then {
            systemChat format["Created SAM site: %1 @ %2", _sstype, _deployment select 0];
        };

        ["IntelRed", ["LANDSAT: New long-range threats discovered!"]] remoteExec ["BIS_fnc_showNotification"];

		//sleep 4000;
	//};
};

fnc_toggleHCL = {
    HCL_ENABLED = !HCL_ENABLED;
    publicVariable "HCL_ENABLED";
    if (HCL_ENABLED) then {
        ["IntelGreen", ["Headless Client Enabled"]] remoteExec ["BIS_fnc_showNotification"];
    } else {
        systemChat "[SERVER] HCL Disabled";
        ["IntelGreen", ["Headless Client Disabled"]] remoteExec ["BIS_fnc_showNotification"];
    };
};

// HVTs
[] spawn {
    while {true} do {
        
        execVM "functions\server\fnc_spawn_high_value_target.sqf"; // HVT

        sleep selectRandom[900, 960, 130];

        if (count (profileNamespace getVariable ["CAPTURED_SECTORS", []]) > 0) then {
            private _args = [
                [
                    call fnc_getEnemySector select 1,
                    3,
                    500,
                    3,
                    0,
                    20,
                    0
                ] call BIS_fnc_findSafePos, 
                [true] call fnc_getEnemySector select 1,
                selectRandom[300, 500, 800, 1200]
            ];
            if (!hasInterface && isServer) then { // Todo: Check if HC is available for patrol spawn // call fnc_HcOnline (untested)
                [_args, "functions\fnc_spawn_patrol.sqf"] remoteExec ["execVM", hc1];
            } else {
                _args execVM "functions\fnc_spawn_patrol.sqf";
            };
        };

        sleep selectRandom[200, 300, 400]; // 15, 16, 17 minutes
    };
};

[] spawn {
	while {true} do {
		0 setfog 0; // Fuck Fog, all my homies hate fog!!!
		forceWeatherChange; 
		sleep 150; //  2.5 minute loop
	};
};

[] spawn {
    systemChat "Initializing Persistant Objects...";
    call fnc_initializeAllPersistentObjects;
    systemChat "Persistent objects initialized";
};

setTimeMultiplier TIME_MULTIPLIER;
systemChat format["[SERVER] Time Multipier set to %1x", TIME_MULTIPLIER];
