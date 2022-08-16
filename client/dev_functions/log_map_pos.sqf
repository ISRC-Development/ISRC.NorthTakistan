	player addAction
	[
		"<t color='#00FFFF' font='PuristaBold'>[DEV] Map Pos To Clipboard</t>",	// title
		{
			params ["_target", "_caller", "_actionId", "_arguments"]; // script
			openMap true;
			player onMapSingleClick {
				onMapSingleClick '';
				copyToClipboard str _pos;
				hint format ["Map position %1 copied to clipboard", _pos];
				openMap false;
				[_pos] spawn {
					params ["_pos"];
					private _marker = createMarker ["MapPos", _pos];
					_marker setMarkerColor "ColorGreen";
					_marker setMarkerType "mil_dot";
					_marker setMarkerSize [1.5, 1.5];
					_marker setMarkerText format ["%1: %2", name player, _pos];
					sleep 500;
					deleteMarker _marker;
				};
				true
			};
		},
		nil,		// arguments
		0.5,		// priority
		false,		// showWindow
		false,		// hideOnUse
		"",			// shortcut
		"true", 	// condition
		50,			// radius
		false,		// unconscious
		"",			// selection
		""			// memoryPoint
	];


