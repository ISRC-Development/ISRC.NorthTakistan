params["_classname", "_pos"];
if (isNil "_pos") exitWith {
	systemChat format ["IED Debug: Invalid pos %1", _pos];
};
private _ied_obj = createMine [_classname, [_pos select 0, _pos select 1, 0], [], 0];
_ied_obj setdir (random 360);
_ied_obj setVectorUp surfaceNormal (getposATL _ied_obj);
[_ied_obj] spawn {
	params["_ied_obj"];
	private _exploded = false;
	while {!(_exploded) && (alive _ied_obj)} do {
		sleep 2;
		private _nearest_dudes = ASLToAGL getPosASL _ied_obj nearEntities [["Man", "Car", "Motorcycle", "Tank", "Truck"], selectRandom[5, 8, 10, 12, 14, 15]];
		if (count (_nearest_dudes) > 0) then {
			{
				if (side _x == WEST && (!([_x] call ace_common_fnc_isEOD) || !("Keeper" in roleDescription _x))) exitWith {_ied_obj setDamage 1};
			} forEach _nearest_dudes;
		};
	};
};

[_ied_obj, ["HandleDamage", {
	params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];
	_unit setDamage 1;
}]] remoteExec ["addEventHandler", -2, true];