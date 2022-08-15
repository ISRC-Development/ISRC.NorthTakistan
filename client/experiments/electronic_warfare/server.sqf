call compileFinal preprocessFileLineNumbers "client\experiments\electronic_warfare\config.sqf";

// Init applicable vehicles
{
	
	[_x, "init",
	{ 
		private _vehicle = (_this select 0);

		if (typeOf _vehicle == "UK3CB_C_AC500") then { // AC-500 <3
		
			[
				_vehicle,
				["CIV_4",1], 
				true
			] call BIS_fnc_initVehicle;

			// Attach Objects to the bird
			private _s_left = "Land_PortableServer_01_black_F" createVehicle [0, 0, 0];
			_s_left setVariable ["is_prop", true];
			_s_left attachTo [_vehicle, [1, -1, 1.60]]; // [left/right, forward/back, up/down]
			_s_left enableSimulationGlobal false;
			//TEST_server_left setDir ((getDir _vehicle) - 180);

			private _s_right = "Land_PortableServer_01_black_F" createVehicle [0, 0, 0];
			_s_right setVariable ["is_prop", true];
			_s_right attachTo [_vehicle, [-1, -1, 1.60]]; // [left/right, forward/back, up/down]
			_s_right enableSimulationGlobal false;
			//TEST_server_right setDir ((getDir _vehicle) - 180);

/*
			private _p_back = "Land_Pipes_small_F" createVehicle [0, 0, 0];
			_p_back setVariable ["is_prop", true];
			_p_back attachTo [_vehicle, [0, -2.5, 0.5]]; // [left/right, forward/back, up/down]
			_p_back enableSimulationGlobal false;
			_p_back setDir ((getDir _vehicle) - 1.8);
*/


		};

		{
			_vehicle addWeaponTurret ["CMFlareLauncher", _x];
			_vehicle addMagazineTurret ["300Rnd_CMFlare_Chaff_Magazine", _x, ISRCEWS_STARTING_CHAFF_AMOUNT];
		} forEach (allTurrets [_vehicle, true]);
		_vehicle setVariable ["ace_rearm_scriptedLoadout", true, true];

	},
	true,
	[],
	true
	] call CBA_fnc_addClassEventHandler;

	[_x, "Deleted",
		{ 
			private _vehicle = (_this select 0);
			{
				detach _x;
				deleteVehicle _x;
			} forEach attachedObjects _vehicle;
		},
		true,
		[],
		true
	] call CBA_fnc_addClassEventHandler;	

} forEach (ISRCEWS_ALLOWED_PLATFORMS);