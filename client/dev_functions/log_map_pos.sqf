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


