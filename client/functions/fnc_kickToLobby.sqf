params[["_announce", false]];
if (_announce) then {
	[format["%1 has been kicked to lobby by a moderator!", name player]] remoteExec ["systemChat"];
};
(findDisplay 46) closeDisplay 2;