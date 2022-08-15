[] spawn {
	disableSerialization;
	private _html = findDisplay 46 createDisplay "RscCredits" ctrlCreate ["RscHTML", -1];
	_html ctrlSetBackgroundColor [0,0,0,0.8];
	_html ctrlSetPosition [0.25, 0, (safeZoneW / 3), safeZoneH * 0.75];
	_html ctrlCommit 0;
	_html htmlLoad "http://isrcartel.com/manager/api/endpoints/newsfeed.php";
};