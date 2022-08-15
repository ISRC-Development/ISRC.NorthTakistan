params ["_tickets", "_time_left"];

// Shows a small GUI list with the current active sectors.
with uiNamespace do 	
{ 
	[_tickets, _time_left] spawn {
		params ["_tickets", "_time_left"];

		disableSerialization;
		ctrl = findDisplay 46 createDisplay "RscDisplayEmpty" ctrlCreate ["RscStructuredText", 1];
		ctrl ctrlSetPosition [0.5 * (safeZoneW / 2), 0.4, 0.4 * (safeZoneH / 2), 0.2 * safeZoneW];

		private _struct_text = format["
		<br />
		<t font='PuristaBold' align='center' size='0.85' color='#ffffff' alpha='1.0'>Crate Tickets:</t>
		<br />
		<t font='PuristaBold' align='center' size='0.75' color='#ffffff' alpha='1.0'>%1</t>
		<br />
		<br />
		<t font='PuristaBold' align='center' size='0.85' color='#ffffff' alpha='1.0'>Next Ticket:</t>
		<br />
		<t font='PuristaBold' align='center' size='0.75' color='#ffffff' alpha='1.0'>%2</t>		
		<br />
		", _tickets, [_time_left, "HH:MM:SS"] call BIS_fnc_secondsToString];

		ctrl ctrlSetStructuredText parseText _struct_text;
		ctrl ctrlSetBackgroundColor [0,0,0,0.5];
		ctrl ctrlCommit 0;
		waitUntil {ctrlCommitted ctrl};
	};
};