	player addAction
	[
		"<t color='#00FFFF' font='PuristaBold'>[DEV] Log Nearest Objects (50m) Clipboard</t>",	// title
		{
			params ["_target", "_caller", "_actionId", "_arguments"]; // script
			openMap true;
			player onMapSingleClick {
				onMapSingleClick '';
				private _near = (nearestObjects [_pos, [], 50] - [player]);
				private _out = [];
				{
					_out pushBack (typeOf _x);
				} forEach _near;
				copyToClipboard str _out;
				hint format ["Copied to %1 objects to clipboard", count _near];
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

