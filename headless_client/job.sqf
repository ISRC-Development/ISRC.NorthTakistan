fnc_callSpawnerHC = {
	params["_thatTrigger"];
	[_thatTrigger] spawn {
		[_this select 0] execVM 'functions\server\fnc_spawner.sqf';
	};
};

fnc_processAIGroup = {
	params["_group", "_isEnemy", "_patrol", ["_isCrew", false]];

	_group deleteGroupWhenEmpty true;

	//{[_unit] call fnc_setRandomIdentity} forEach units _group;
	
	{
		if (typeOf _x in (call fnc_getAllOpInfantry)) then {
			_isEnemy = true;	
		};	
	} forEach units _group;

	if (_isEnemy) then {
		[_group] call fnc_aggressive_ai;
	};

	if (count _patrol > 0) then {
		private _patrol_pos = _patrol select 0;
		private _patrol_rad = _patrol select 1;
		[_group, _patrol_pos, _patrol_rad] call BIS_fnc_taskPatrol;			
	};

/*
	if !(_isCrew) then {
		{
			[_x] spawn {
				params["_unit"];
				_unit setUnconscious true;
				sleep 5;
				_unit setUnconscious false;
				_unit setPos ((getPosATL _unit) vectorAdd [0, 0, 0.07]);
			};		
		} forEach units _group;	
		[_group, 25] call fnc_delete_lazy_dudes; // delete lazy dudes - 30 seconds???
	};
*/
};

fnc_processCivlian = {
	params["_unit"];
	[_unit] call fnc_civilianAccountablity;
	[_unit, ["HAS_BEEN_FED", false]] remoteExec ["setVariable", 0, _unit]; 

	private "_id";
	if ("Female" in (typeOf _unit)) then {
		// is female
		private _id = [false, selectRandom[0, 1, 2]] call fnc_randomIdentity;
		_unit setIdentity _id;
		[_unit, _id] remoteExec ["setIdentity", 0, _unit];	
	} else {
		// is male
	};
};

fnc_new_HC_job = {

	params["_job_name", ["_args", []]];
	// Note: Keep support for server to run this if need be (no HC's online etc)
	// TODO: HC Zombie manager
	// Note: $_isenemy determines whether or not to apply fnc_aggressive_ai to the group.
	switch (_job_name) do {

		case "spawn_ssb_ped": {
			private _classname = _args select 0;
			private _pos       = _args select 1;
			private _group     = createGroup civilian;
			private _unit      = _group createUnit [_classname, [_pos, 1, 50, 2, 0, 30, 0] call BIS_fnc_findSafePos, [], 0, "NONE"];
			[_group, false, [], false] call fnc_processAIGroup;
			_group addWaypoint [[_unit, 3] call fnc_inFrontOf, 0];
			[_group] execVM "functions\server\ssb.sqf";
		};

		case "spawn_ssb_motorist": {
			private _unitClass    = _args select 0;
			private _vehicleClass = _args select 1;
			private _pos          = _args select 2;
			private _group    	  = createGroup civilian;
			private _unit      	  = _group createUnit [_unitClass, [_pos, 1, 50, 2, 0, 30, 0] call BIS_fnc_findSafePos, [], 0, "NONE"];
			private _vehicle      = _vehicleClass createVehicle ([_pos, 1, 50, 2, 0, 30, 0] call BIS_fnc_findSafePos);	
			_unit moveInAny _vehicle;
			[_vehicle] call fnc_cleanVehicle;
			//[_group, false, [], false] call fnc_processAIGroup;
			//_group addWaypoint [[_unit, 3] call fnc_inFrontOf, 0];
			[_group] execVM "functions\server\ssb.sqf";
		};

		case "spawn_civilian_motorist": {
			private _unitClass    = _args select 0;
			private _vehicleClass = _args select 1;
			private _pos          = _args select 2;
			private _group    	  = createGroup civilian;
			private _unit      	  = _group createUnit [_unitClass, [_pos, 1, 50, 2, 0, 30, 0] call BIS_fnc_findSafePos, [], 0, "NONE"];
			private _vehicle      = _vehicleClass createVehicle ([_pos, 1, 50, 2, 0, 30, 0] call BIS_fnc_findSafePos);
			_unit moveInAny _vehicle;
			[_vehicle] call fnc_cleanVehicle;
			[_group, false, [], false] call fnc_processAIGroup;
			_group addWaypoint [[_unit, 3] call fnc_inFrontOf, 0];
			[_unit] call fnc_processCivlian;
			[_group, _pos, 800] call BIS_fnc_taskPatrol;
		};

		case "spawn_civilian_ped": {
			private _classname = _args select 0;
			private _pos       = _args select 1;
			private _group     = createGroup civilian;
			private _unit      = _group createUnit [_classname, [_pos, 1, 50, 2, 0, 30, 0] call BIS_fnc_findSafePos, [], 0, "NONE"];
			[_group, false, [], false] call fnc_processAIGroup;
			[_unit] call fnc_processCivlian;
			[_group, _pos, 800] call BIS_fnc_taskPatrol;
		};

		case "spawn_man": 
		{
			private _side 	   = _args select 0; // side of group
			private _classname = _args select 1; // classname of unit
			private _pos       = _args select 2; // spawn pos
			private _isenemy   = _args select 3; // is enemy
			private _patrol    = _args select 4; // array: [_pos, _radius]; do patrol around _pos
			private _group     = createGroup _side;
			private _unit 	   = _group createUnit [_classname, [_pos, 1, 50, 2, 0, 30, 0] call BIS_fnc_findSafePos, [], 0, "NONE"];
			[_group, _isenemy, _patrol, false] call fnc_processAIGroup;
		};

		case "spawn_group": {
			private _side 	   = _args select 0; // side of group
			private _groupArray= _args select 1; // array of classnames of the group's units
			private _pos       = _args select 2; // spawn pos
			private _isenemy   = _args select 3; // is enemy
			private _patrol    = _args select 4; // array: [_pos, _radius]; do patrol around _pos
			
			private _group     = createGroup _side;
			{
				private _unit = _group createUnit [_x, [_pos, 1, 50, 2, 0, 30, 0] call BIS_fnc_findSafePos, [], 0, "NONE"];
			} forEach _groupArray;

			if (count _args > 5) then {
				/*
				Spawneropts: 
					This connects groups spawned by the HC/Server "Jobs" system to the spawner system.
				*/
				// Check for spawneropts array
				// [spawneropts, [_sector_pos, _sector_name, _sector_type, _sector_infantry_radius, _sector_id]];
				private _spawneropts      = _args select 5;
				private _spawneropts_args = _spawneropts select 1;	
				private _opts_pos    	  = _spawneropts_args select 0;
				private _opts_name   	  = _spawneropts_args select 1;
				private _opts_type   	  = _spawneropts_args select 2;
				private _opts_radius 	  = _spawneropts_args select 3;
				private _opts_id     	  = _spawneropts_args select 4;

				// Post-spawn infantry group processing below ///////////////////////////

				// Check if garrisonable
				private _nearestBuilding = [leader _group] call isrc_ufnc_getNearestBuildingPos;
				if !(isNil "_nearestBuilding") then { 
					if (((leader _group) distance2d _nearestBuilding) <= floor (_opts_radius * SPAWNOPTS_INFANTRY_GARRISON_COEF)) then {
						//_group addWaypoint [_nearestBuilding, -1] setWaypointScript "\x\cba\addons\ai\fnc_waypointGarrison.sqf []"; // alternate syntax/method?
						[_group, _nearestBuilding] execVM "\x\cba\addons\ai\fnc_waypointGarrison.sqf"; // https://cbateam.github.io/CBA_A3/docs/files/ai/fnc_waypointGarrison-sqf.html
						systemChat format ["Garrisoning %1 at %2", _group, _nearestBuilding];
						_patrol = []; // make $patrol default so they arent tasked to multiple waypoints.
					};
				};

				// END Post-spawn infantry group processing /////////////////////////////

			};
			

			[_group, _isenemy, _patrol, false] call fnc_processAIGroup;
		};

		case "spawn_crewed_vehicle": {
			private _classname = _args select 0;
			private _pos       = _args select 1;
			private _isenemy   = _args select 2;
			private _patrol    = _args select 3;
			private "_vehicle";
			if (_classname in ISRC_ENEMY_AIR) then {
				_vehicle       = createVehicle [_classname, _pos, [], 0, "FLY"];
			} else {
				if (_classname in ISRC_ENEMY_MARINE) then {
					_vehicle 	   = _classname createVehicle _pos;
				} else {
					_vehicle 	   = _classname createVehicle ([_pos, 1, 50, 2, 0, 30, 0] call BIS_fnc_findSafePos);
				};			
			};
			
			private _crew      = createVehicleCrew _vehicle;

			if (_classname == ISRC_transport_rotary) then {
				private _para_group = group driver _vehicle;
				{
					private _unit = _para_group createUnit [
						_x,
						[[0, 0, 0], 1, 50, 2, 0, 30, 0] call BIS_fnc_findSafePos,
						[],
						0,
						"NONE"
					];
					_unit moveInAny _vehicle;
				} forEach ISRC_paras;
				private _waypoint = _para_group addWaypoint [[0, 0, 0], -1];
				_waypoint setWaypointPosition [[_pos, side leader _para_group] call isrc_ufnc_getNearestEnemyToUnit, -1];
				_waypoint setWaypointType "MOVE";
				_waypoint setWaypointName "ISRC Paradrop";
				_waypoint setWaypointDescription "";
				_waypoint setWaypointFormation "NO CHANGE";
				_waypoint setWaypointBehaviour "UNCHANGED";
				_waypoint setWaypointCombatMode "RED";
				_waypoint setWaypointSpeed "FULL";
				//_waypoint setWaypointTimeout [0,0,0];
				_waypoint setWaypointCompletionRadius 50;
				_waypoint setWaypointStatements ["true",""];
				_waypoint setWaypointScript "\x\zen\addons\ai\functions\fnc_waypointParadrop.sqf []";
				_patrol = [];
			};

			// Review 
			if (_classname == "min_rf_Mortar") then {
				private _unit = units _crew select 0;
				{
					if ((side _x) == west) then {
						_unit reveal _x;
						_unit setVariable ["is_mortarman", true];
					};

				} forEach allUnits;
			};	
			[_crew, _isenemy, _patrol, true] call fnc_processAIGroup;
			_vehicle addEventHandler ["Fired", {(_this select 0) setVehicleAmmo 1}];
			[_vehicle] call fnc_cleanVehicle;
		};		

		case "create_battlegroup": {
			execVM "server\battlegroup.sqf";
		};

		default { };
	};
};