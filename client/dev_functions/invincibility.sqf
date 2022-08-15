player addAction
[
	"<t color='#00FFFF' font='PuristaBold'>[DEV] Toggle Invincibility</t>",	// title
	{
		params ["_target", "_caller", "_actionId", "_arguments"]; // script
		ALLOW_DAMAGE = !ALLOW_DAMAGE;
		player allowDamage ALLOW_DAMAGE;
		hint format ["Allowing Damage: %1", ALLOW_DAMAGE];
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



