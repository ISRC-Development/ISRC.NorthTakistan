	player addAction
	[
		"<t color='#00FFFF' font='PuristaBold'>[DEV] Map Pos To Clipboard W/ Grid Pos</t>",	// title
		{
			params ["_target", "_caller", "_actionId", "_arguments"]; // script
			openMap true;
			player onMapSingleClick {
				onMapSingleClick '';
				private _string = format['[%1, "%2"]', _pos, mapGridPosition _pos];
				copyToClipboard _string;
				private _n = [6] call fnc_genId;
				private _m = createMarkerLocal[_n, _pos];
				_n setMarkerType "mil_dot";
				_n setMarkerColor "ColorGreen";
				hint format ["%1 copied to clipboard", _string];
				openMap false;
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


