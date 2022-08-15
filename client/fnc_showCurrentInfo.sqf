/*
[
	1.063,
	["activesectors",[[0,0,1,1],0.025,0.04,"GUI_GRID"],0,0,0],
	[1800,"",[0,"Active Sectors",[1,0.8,0.2,0.2],[-1,-1,-1,-1],[-1,-1,-1,1],[-1,-1,-1,-1],"","1"],[]],
	[1500,"",[0,"",[1,0.82,0.2,0.18],[-1,-1,-1,-1],[-1,-1,-1,-1],[-1,-1,-1,-1],"","0.6"],[]]
]
*/

// Shows a small GUI list with the current active sectors.
with uiNamespace do 	
{ 
	[] spawn {

		disableSerialization;

		private _sectors = [missionNamespace, "ACTIVE_SECTORS", []] call BIS_fnc_getServerVariable;

		private _civrep =  [profilenamespace, "CIV_RATING", 0] call BIS_fnc_getServerVariable;

		private _funding = format["$%1", (([[profilenamespace, "CURRENT_FUNDING_BALANCE", 0] call BIS_fnc_getServerVariable] call BIS_fnc_numberText) splitString " ") joinString ","];

		//systemChat format ["%1 civ rep: %2", _funding, _civrep];

		ctrl = findDisplay 46 createDisplay "RscDisplayEmpty" ctrlCreate ["RscStructuredText", 1];
		ctrl ctrlSetPosition [0.5 * (safeZoneW / 2), 0.4, 0.4 * (safeZoneH / 2), 0.2 * safeZoneW];

		// https://community.bistudio.com/wiki/Structured_Text

		// Active sectors
		private _struct_text = "<br /><t font='PuristaBold' align='center' size='0.85' color='#ffffff' alpha='1.0'>Active Sectors:</t>";
		
		if (count _sectors > 0) then {
			{
				_struct_text = _struct_text + format["<br /> <img  align='center' size='.7' image='\A3\ui_f\data\map\markers\nato\o_unknown.paa' /> <t align='center' size='0.7' color='#ff0000'><br />%1</t>", _x];
			} forEach _sectors;
		} else {
			_struct_text = _struct_text + "<br/><t font='PuristaBold' align='center' size='.7' color='#00ff00'>None</t>";
		};

		private _repcolor = "";
		if (_civrep >= 75) then {
			_repcolor = '#00ff00'; // Green
		};
		if (_civrep < 75 && _civrep >= 50) then {
			_repcolor = '#ffff00'; // Yellow
		};
		if (_civrep < 50 && _civrep >= 25) then {
			_repcolor = '#ffa500'; // Orange
		};
		if (_civrep < 25) then {
			_repcolor = '#ff0000'; // Red
		};

		// Civ rep
		private _outof = format[
			"<t font='PuristaBold' align='center' size='0.7' color='#ffffff' alpha='1.0'>/100</t>"];

		_struct_text   = format[
			"%1<br /> <t font='PuristaBold' align='center' size='0.85' color='#ffffff' alpha='1.0'>Reputation:</t> <t font='PuristaBold' align='center' alpha='0.8' size='0.7' color='%2'><br />%3</t>%4", _struct_text, _repcolor, _civrep, _outof];

		// Funding
		_struct_text = format[
			"%1<br /> <t font='PuristaBold' align='center' size='0.85' color='#ffffff' alpha='1.0'>Funding:</t> <t font='PuristaBold' align='center' alpha='1.0' size='0.7' color='#ffffff'><br />%2</t>", _struct_text, _funding];


		ctrl ctrlSetStructuredText parseText _struct_text;
		ctrl ctrlSetBackgroundColor [0,0,0,0.5];
		ctrl ctrlCommit 0;
		waitUntil {ctrlCommitted ctrl};
	};
};