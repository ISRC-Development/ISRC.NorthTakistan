params["_group", ["_maxRange", 1000]];

// sort grp
if (!local _group) exitWith {};
if (_group isEqualType objNull) then {_group = group _group;};

// if (_group getVariable ["isrc_mortar_team", false]) exitWith {}; 

{
	_x setSkill ["commanding",     1];
	_x setSkill ["spotDistance",   1];
	_x setSkill ["spotTime",       1];  
} forEach units _group;

_group setVariable ["isrc_mortar_team", true];

systemChat format ["Group: %1", _group];

private _mags = vehicle leader _group magazinesTurret;
systemChat format ["Mags: %1", _mags];
private _mag = false;
{
	systemChat format ["This Mag: %1", _x];
	private _class = _x select 0;
	private _path  = _x select 1;
	private _count = _x select 2;
	private _id    = _x select 3;
	private _owner = _x select 4;
	if (_count > 0) exitWith {_mag = _class};
} forEach _mags;					

systemChat format ["Mag: %1", _mag];

sleep 5;

leader _group doArtilleryFire [getPos player, _mag, floor(random 8)];


/*
[leader _group, "KnowsAboutChanged", {
	params ["_group", "_targetUnit", "_newKnowsAbout", "_oldKnowsAbout"];
	systemChat format ["%1 is aware of %2!", name _group, name _targetUnit];
	if (side _targetUnit == WEST) then {
		{
			if (_x distance2D _targetUnit <= _maxRange && !(isNull objectParent _x)) then {		

				// Random pos near player
				private _randpos = [[[getPos _targetUnit, floor(random 100)]], []] call BIS_fnc_randomPos; 

				// Get first available ammo type
				private _mags = magazinesAllTurrets vehicle _x;
				private _mag = false;
				{
					private _class = _x select 0;
					private _path  = _x select 1;
					private _count = _x select 2;
					private _id    = _x select 3;
					private _owner = _x select 4;
					if (_count > 0) exitWith {_mag = _class};
				} forEach _mags;					
				systemChat format ["%1 has %2 magazines", _x, _mags];

				if (typeName _mag != "BOOL") then {
					systemChat format ["%1 is firing at", _x, _targetUnit];
					_x doArtilleryFire [_randpos, _mag, floor(random 8)];
				} else {
					_group removeEventHandler ["KnowsAboutChanged", 0];
				};

			};
		} forEach units _group;
	};
}] call CBA_fnc_addBISEventHandler;
*/