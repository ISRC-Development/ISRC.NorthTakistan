fnc_applyAddactions = {
	params["_unit"];

	// Deploy to COP
	ISRC_my_addactions set ["deploy_to_cop",  _unit addAction
	[
		"<t color='#FFFF00' font='PuristaBold'>[DEPLOYMENT] Deploy To FLP Alpha</t>",	// title
		{
			params ["_target", "_caller", "_actionId", "_arguments"]; // script
			[] spawn {
				if (["You are about to be deployed to FLP Alpha, would you like to continue?", "Confirm", true, true] call BIS_fnc_guiMessage) then {
					if !(isNull objectParent player) then {
						private _vehicle = vehicle player;
						_vehicle setDir 0;
						_vehicle setPos COP_LOCATION;
					} else {
						player setPos COP_LOCATION;
					};
				};
			};
		},
		nil,		// arguments
		1.5,		// priority
		false,		// showWindow
		false,		// hideOnUse
		"",			// shortcut
		"typeName COP_LOCATION != 'BOOL' && (player distance2D RESPAWN_LOCATION < 80 || player distance2D FOB_BRAVO_LOCATION < 80 || player distance2D FOB_CHARLIE_LOCATION < 80)", 	// condition
		50,			// radius
		false,		// unconscious
		"",			// selection
		""			// memoryPoint
	]];

	// Deploy to FOB Alpha
	ISRC_my_addactions set ["deploy_to_alpha",  _unit addAction
	[
		"<t color='#FFFF00' font='PuristaBold'>[DEPLOYMENT] Deploy To FOB Alpha</t>",	// title
		{
			params ["_target", "_caller", "_actionId", "_arguments"]; // script
			[] spawn {
				if (["You are about to deploy to FOB Alpha, would you like to continue?", "Confirm", true, true] call BIS_fnc_guiMessage) then {
					if !(isNull objectParent player) then {
						private _vehicle = vehicle player;
						_vehicle setDir 0;
						_vehicle setPos RESPAWN_LOCATION; // using ASL for nimitz etc
					} else {
						player setPos RESPAWN_LOCATION;
					};
				};
			};
		},
		nil,		// arguments
		1.5,		// priority
		false,		// showWindow
		false,		// hideOnUse
		"",			// shortcut
		"(player distance2D FOB_BRAVO_LOCATION < 80 || player distance2D COP_LOCATION < 80 || player distance2D FOB_CHARLIE_LOCATION < 80)", 	// condition
		50,			// radius
		false,		// unconscious
		"",			// selection
		""			// memoryPoint
	]];

	if (FOB_BRAVO_LOCATION select 0 != 0) then {
		// Deploy to FOB 2 (BRAVO)
		ISRC_my_addactions set ["deploy_to_bravo",  _unit addAction
		[
			"<t color='#FFFF00' font='PuristaBold'>[DEPLOYMENT] Deploy To FOB Bravo</t>",	// title
			{
				params ["_target", "_caller", "_actionId", "_arguments"]; // script
				[] spawn {
					if (["You are about deploy to FOB Bravo, would you like to continue?", "Confirm", true, true] call BIS_fnc_guiMessage) then {
						if !(isNull objectParent player) then {
							private _vehicle = vehicle player;
							_vehicle setDir 0;
							_vehicle setPos FOB_BRAVO_LOCATION;
						} else {
							player setPos FOB_BRAVO_LOCATION;
						};
					};
				};
			},
			nil,		// arguments
			1.5,		// priority
			false,		// showWindow
			false,		// hideOnUse
			"",			// shortcut
			"(player distance2D RESPAWN_LOCATION < 80 || player distance2D FOB_CHARLIE_LOCATION < 80 || player distance2D COP_LOCATION < 80)", 	// condition
			50,			// radius
			false,		// unconscious
			"",			// selection
			""			// memoryPoint
		]];
	};

	if (FOB_CHARLIE_LOCATION select 0 != 0) then {
		// Deploy to FOB 3 (CHARLIE)
		ISRC_my_addactions set ["deploy_to_charlie",  _unit addAction
		[
			"<t color='#FFFF00' font='PuristaBold'>[DEPLOYMENT] Deploy To FOB Charlie</t>",	// title
			{
				params ["_target", "_caller", "_actionId", "_arguments"]; // script
				[] spawn {
					if (["You are about deploy to FOB Charlie, would you like to continue?", "Confirm", true, true] call BIS_fnc_guiMessage) then {
						if !(isNull objectParent player) then {
							private _vehicle = vehicle player;
							_vehicle setDir 0;
							_vehicle setPos FOB_CHARLIE_LOCATION;
						} else {
							player setPos FOB_CHARLIE_LOCATION;
						};
					};
				};
			},
			nil,		// arguments
			1.5,		// priority
			false,		// showWindow
			false,		// hideOnUse
			"",			// shortcut
			"(player distance2D RESPAWN_LOCATION < 80 || player distance2D FOB_BRAVO_LOCATION < 80 || player distance2D COP_LOCATION < 80)", 	// condition
			50,			// radius
			false,		// unconscious
			"",			// selection
			""			// memoryPoint
		]];
	};

	// Civilian Rations
	ISRC_my_addactions set ["civ_ration", _unit addAction
	[
		"<t color='#00FF00' font='PuristaBold'>GIVE RATION</t>",	// title
		{
			params ["_target", "_caller", "_actionId", "_arguments"]; // script
			private _civ = [];
			{
				if (side _x == civilian) then {
					_civ pushBack _x;
				};
			} forEach (player nearEntities [["Man"], 100] - [player]);

			if (count _civ > 0) then {
				_civ = _civ select 0;
			} else {
				hint "You are too far away!";
			};
			
			if (_civ getVariable ["HAS_BEEN_FED", false] == false) then {
				[] remoteExec ["fnc_civRateAdd", 2];
				[_civ, ["HAS_BEEN_FED", true]] remoteExec ["setVariable", 0, _civ]; // JIP this to the civ for new joins
				["IntelGreen", ["+1 Reputation:<br/>Humanitarian Aid"]] remoteExec ["BIS_fnc_showNotification", -2];			
			} else {
				hint format["%1 has already received assistance.", name _civ];
			};
			
		},
		nil,		// arguments
		1.5,		// priority
		false,		// showWindow
		false,		// hideOnUse
		"",			// shortcut
		"(alive cursorTarget && side cursorTarget == civilian && cursorTarget isKindOf 'Man' && {player distance cursorTarget < 3} && [player, 'ACE_Humanitarian_Ration'] call BIS_fnc_hasItem)", 	// condition
		50,			// radius
		false,		// unconscious
		"",			// selection
		""			// memoryPoint
	]];

	/*
	_unit addAction
	[
		"Claim Reward For Prisoner",	// title
		{
			params ["_target", "_caller", "_actionId", "_arguments"]; // script
		
			[] remoteExec ["fnc_civRateAdd", 2];
			[_civ, "HAS_BEEN_FED", true, true] remoteExec ["setVariable", 0]; 
			_civ setVariable ["HAS_BEEN_FED", true, true];
			["IntelGreen", ["+1 Reputation:<br/>Humanitarian Aid"]] remoteExec ["BIS_fnc_showNotification", -2];			

			
		},
		nil,		// arguments
		1.5,		// priority
		false,		// showWindow
		false,		// hideOnUse
		"",			// shortcut
		"(alive cursorTarget && side cursorTarget == civilian && {player distance cursorTarget < 3} && [player, 'ACE_Humanitarian_Ration'] call BIS_fnc_hasItem)", 	// condition
		50,			// radius
		false,		// unconscious
		"",			// selection
		""			// memoryPoint
	];
	*/

	// Commander Actions
	if (("Legion 6" in roleDescription _unit) || ("Bishop" in roleDescription _unit) || ("Keeper" in roleDescription _unit) || ("1-6" in roleDescription _unit)) then {
		ISRC_my_addactions set ["commander_purchase_cop", _unit addAction
		[
			"<t color='#00FF00' font='PuristaBold'>[ENGINEER] Move FLP</t>",	// title
			{
				params ["_target", "_caller", "_actionId", "_arguments"]; // script
				[] spawn {
					private _CURRENT_FUNDING_BALANCE = [missionNamespace, "CURRENT_FUNDING_BALANCE", 0] call BIS_fnc_getServerVariable;
					if (_CURRENT_FUNDING_BALANCE >= COP_DEPLOY_MOVE_PRICE) then
					{
						private _result = ["Forward Outpost is ready to be built/moved. Would you like to continue?", "Confirm", true, true] call BIS_fnc_guiMessage;
						if (_result) then {
							hint "Select a position on the map to deploy the Forward Outpost.";
							openMap true;
							player onMapSingleClick {
								onMapSingleClick '';
								[[_pos], "functions\server\fnc_spawnCOP.sqf"] remoteExec ["execVM", 2];
								player setPos _pos;
								openMap false;
								true
							};
						};  
					} else {
						systemChat "You do not have enough funds to purchase this item.";
					};
				};
			},
			nil,		// arguments
			0.5,		// priority
			false,		// showWindow
			false,		// hideOnUse
			"",			// shortcut
			"((player distance2D RESPAWN_LOCATION) < 50)", 	// condition
			50,			// radius
			false,		// unconscious
			"",			// selection
			""			// memoryPoint
		]];
		ISRC_my_addactions set ["commander_purchase_menu", _unit addAction
		[
			"<t color='#00FF00' font='PuristaBold'>[ENGINEER] Purchase Vehicles</t>",	// title
			{
				params ["_target", "_caller", "_actionId", "_arguments"]; // script
				[] spawn {
					execVM "client\build_menu.sqf";
				};
			},
			nil,		// arguments
			0.5,		// priority
			false,		// showWindow
			false,		// hideOnUse
			"",			// shortcut
			"( typeName COP_LOCATION != 'BOOL' && (player distance2D RESPAWN_LOCATION) < 100 || (player distance2D COP_LOCATION) < 100 || (player distance2D FOB_BRAVO_LOCATION) < 100)", 	// condition
			50,			// radius
			false,		// unconscious
			"",			// selection
			""			// memoryPoint
		]];	
		/*
			ISRC_my_addactions set ["commander_start_humanitarian", _unit addAction
			[
				"<t color='#00FF00' font='PuristaBold'>[ENGINEER] Side Operation: Humanitarian Mission</t>",	// title
				{
					params ["_target", "_caller", "_actionId", "_arguments"]; // script
					[] spawn {
						private _result = ["Side Operation: Humanitarian Mission is ready to be commenced. Would you like to continue?", "Confirm", true, true] call BIS_fnc_guiMessage;
						if (_result) then {
							hint "Select a position on the map to deploy the beginning of the humanitarian mission. This should be a safe area like a FOB.";
							openMap true;
							player onMapSingleClick {
								onMapSingleClick '';
								[[_pos], "functions\server\side_ops\fnc_side_ops_startHumanitarian.sqf"] remoteExec ["execVM", 2];
								player setPos _pos;
								openMap false;
								true
							};
						};  
					};
				},
				nil,		// arguments
				0.5,		// priority
				false,		// showWindow
				false,		// hideOnUse
				"",			// shortcut
				"((player distance2D RESPAWN_LOCATION) < 50 && (HUMANITARIAN_RUNNING == false))", 	// condition
				50,			// radius
				false,		// unconscious
				"",			// selection
				""			// memoryPoint
			]];
		*/
	};

	// Give Bishop some extra dev-based add-actions.
	if ("Bishop" in roleDescription _unit) then {call compileFinal preprocessFileLineNumbers "client\dev_functions\index.sqf"};

	// object Manipulation Actions
	if ("Bishop" in roleDescription _unit || "Keeper" in roleDescription _unit) then {
		call compileFinal preprocessFileLineNumbers "client\object_placement\index.sqf";
		systemChat "Bishop/Keeper: Object Manipulation Menu is now available!";
	};

	ISRC_my_addactions set ["keeper_right_vehicle", _unit addAction 
	[
		"<t color='#FFFF00' font='PuristaBold'>RIGHT VEHICLE</t>",	// title
		{
			params ["_target", "_caller", "_actionId", "_arguments"]; // script
			private _curtarget = cursorTarget;
			_curtarget setPos ((getPosATL _curtarget) vectorAdd [0, 0, 0.05]);
			_curtarget setVectorUp [0, 0, 1]; // surfaceNormal (getposATL cursorTarget vectorAdd [0, 0, 1])
		},
		nil,		// arguments
		1.0,		// priority
		false,		// showWindow
		false,		// hideOnUse
		"",			// shortcut
		"((cursorTarget distance2D player < 15) && (cursorTarget isKindOf 'Car' || cursorTarget isKindOf 'Truck' || cursorTarget isKindOf 'Tank') && (alive cursorTarget))", 	// condition
		50,			// radius
		false,		// unconscious
		"",			// selection
		""			// memoryPoint
	]];	

	fnc_getCurrentCallout = {
		private _altitude = (getPosATL (vehicle player)) select 2;
		private _div      = 50;
		private _average  = floor (_altitude / _div);
		if (_average >= 2 && _average <= 10) then {
			{format["n_%1", _div * _average] remoteExec ["playSound", _x]} forEach crew (vehicle player);
		};
	};

	ISRC_CALLOUTS_IS_RUNNING = false;
	ISRC_my_addactions set ["isrc_callouts_system", _unit addAction 
	[
		"<t color='#FFFF00' font='PuristaBold'>Toggle Altitude Callouts (100m-500m)</t>",	// title
		{
			params ["_target", "_caller", "_actionId", "_arguments"]; // script
			if (ISRC_CALLOUTS_IS_RUNNING) then {
				ISRC_CALLOUTS_IS_RUNNING = false;
				systemChat "Altitude Callouts Stopped";
			} else {
				private _vehicle = vehicle player;
				ISRC_CALLOUTS_IS_RUNNING = true;
				[_vehicle] spawn {
					params["_vehicle"];
					while {ISRC_CALLOUTS_IS_RUNNING && alive player && !(isNull objectParent player)} do {
						call fnc_getCurrentCallout;
						sleep 3;
					};
				};
				systemChat "Altitude Callouts Started";
			};
		},
		nil,		// arguments
		1.0,		// priority
		false,		// showWindow
		false,		// hideOnUse
		"",			// shortcut
		"((vehicle player) isKindOf 'Plane')", 	// condition
		50,			// radius
		false,		// unconscious
		"",			// selection
		""			// memoryPoint
	]];	



};