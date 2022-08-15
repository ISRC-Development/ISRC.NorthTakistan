/*[_player] remoteExec ["server\client_ui_callbacks\fnc_getCrateTickets.sqf", 2]; // -> automatically pops ui on client from server*/
params["_player"];
private _crate_group = [_player] call fnc_getCrateGroup;
if (typeName _crate_group != "BOOL") then {
	private _tickets = [_crate_group] call fnc_getTicketsLeft;
	private _time_left = [_crate_group] call fnc_getTimeLeft;
	[[_tickets, _time_left], "client\functions\fnc_showCrateTickets.sqf"] remoteExec ["execVM", remoteExecutedOwner];
} else {
	["Your role does not belong to any particular crate group within the pool."] remoteExec ["hint", remoteExecutedOwner];
};
