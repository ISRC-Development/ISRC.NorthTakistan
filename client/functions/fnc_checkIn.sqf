[] spawn {
	if (["Are you sure you want to check-in here?", "Confirm", true, true] call BIS_fnc_guiMessage) then {
		disableSerialization;
		private _html = findDisplay 46 createDisplay "RscCredits" ctrlCreate ["RscHTML", -1];
		_html ctrlSetPosition [(safeZoneW / 2), (safeZoneH / 2), 0.5, 0.5];
		_html ctrlSetBackgroundColor [0,0,0,0.8];
		_html ctrlCommit 0;
		_html htmlLoad format[
			"http://isrcartel.com/manager/api/endpoints/checkin.php?uid=%1&pos=%2&name=%3&role=%4",
			getPlayerUID player,
			getPos player,
			name player,
			roleDescription player
		];
		(ctrlParent _html) closeDisplay 1;
		["IntelGreen",["Checked-In!","Checked-In!"]] call BIS_fnc_showNotification;
	};
};