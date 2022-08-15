params ["_oldUnit", "_killer", "_respawn", "_respawnDelay"];

if (getPlayerUID player == getPlayerUID _oldUnit) then {
	showScoretable 0;
};
