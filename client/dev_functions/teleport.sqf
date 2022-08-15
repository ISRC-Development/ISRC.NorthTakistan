	player addAction
	[
		"<t color='#00FFFF' font='PuristaBold'>[DEV] Teleport To Map Location</t>",	// title
		{
			params ["_target", "_caller", "_actionId", "_arguments"]; // script
			openMap true;
			player onMapSingleClick {
				onMapSingleClick '';
				player setPos _pos;
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





