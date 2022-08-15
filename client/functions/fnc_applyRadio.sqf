/*
	[
		[
			_vehicle,
			["copilot_radio_settings"]
		], "client\functions\fnc_applyRadio.sqf"
	] remoteExec ["execVM", -2];
*/

params[
	"_vehicle",
	["_radio_seats", 
		[
			"gunner_radio_settings",
			"driver_radio_settings",
			"commander_radio_settings",
			"copilot_radio_settings"
		]
	] 
];

_vehicle addEventHandler ["GetIn", {
	params ["_ve", "_role", "_unit", "_turret"];
	{
		[[_ve, _x], 1, "30.0"] call TFAR_fnc_SetChannelFrequency; 
		[[_ve, _x], 1, "40.0"] call TFAR_fnc_SetChannelFrequency; 
		[[_ve, _x], 1, "50.0"] call TFAR_fnc_SetChannelFrequency; 
		[[_ve, _x], 1, "60.0"] call TFAR_fnc_SetChannelFrequency; 
		[[_ve, _x], 1, "70.0"] call TFAR_fnc_SetChannelFrequency; 
	} forEach _radio_seats;
}];