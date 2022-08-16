ACE_maxWeightDrag = 10000; // ?? https://github.com/7Cav/cScripts/issues/10

/*
Notes:
> Per the new headless client framework, Server functions that are not assigned to headless clients should be defined here.
> Any variables that are not defined to the headless client should be set to networked variables in config/settings.sqf.
OOF, ALREADY DEPRECATED
*/
call compileFinal preprocessFileLineNumbers "functions\server\fnc_aggressive_ai.sqf";

fnc_getAllOpInfantry = {
    private _all = [];
    {
        private _type = _x select 1;
        {
            _all pushBack _x;
        } forEach _type;
    } forEach ISRC_ENEMY_INFANTRY;
    _all
};

fnc_inFrontOf = {
	// Gets position of distance in front of object/unit/vehicle
	params["_unitOrObject", "_distance"];
	_pos = getPosATL _unitOrObject;
	_azimuth = getDir _unitOrObject;
	_px = (_pos select 0) + (_distance * (sin _azimuth));
	_py = (_pos select 1) + (_distance * (cos _azimuth));
	[_px, _py, (_pos select 2)]
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

fnc_freezefix = {
    // Freezing hotfix?
    params ["_thisUnit"];
    [_thisUnit] spawn {
        params ["_thisUnit"];
        _thisUnit setUnconscious true;
        sleep 5;
        _thisUnit setUnconscious false;
        _thisUnit setPos ((getPosATL _thisUnit) vectorAdd [0, 0, 0.07]);
    };
};

fnc_delete_lazy_dudes = {
    // Delete the pieces of shit that stay frozen
	params["_group", ["_delay", 20], ["_min_distance", 2]];
	private _gpos_init = [];
	{_gpos_init pushBack [_x, getPos _x]} forEach units _group;
	[_gpos_init, _delay, _min_distance] spawn {
		params["_mngr", "_delay", "_min_distance"];
		sleep _delay;
		{
			private _unit = _x select 0;
			private _pos  = _x select 1;
			if ((_pos distance2D (getPos _unit)) < _min_distance) then {
				deleteVehicle _unit;
			};
		} forEach _mngr;
	};
};

/// TRANSFERS FROM INITSERVER.SQF FOR HCL SUPPORT
fnc_cleanVehicle = {
    params["_vehicle"];
    clearMagazineCargoGlobal _vehicle;
    clearItemCargoGlobal 	 _vehicle;
    clearBackpackCargoGlobal _vehicle;
    clearWeaponCargoGlobal 	 _vehicle;
};

fnc_civilianAccountablity = {
    params["_unit"];
    _unit addEventHandler ["Killed", {
	    params ["_unit", "_killer", "_instigator", "_useEffects"];
        if (side _killer == west) then {
            [] remoteExec ["fnc_civRateSubtract", 2];
            [format["%1 killed a civilian!", name _killer]] call fnc_globalChat;
        };
    }];
};

if (isServer) then {
    HCL_ENABLED = false;
};
