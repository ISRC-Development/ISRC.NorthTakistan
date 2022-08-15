fnc_isUnitCopilot = {
	// https://forums.bohemia.net/forums/topic/180060-how-to-check-if-im-copilot/?do=findComment&comment=2834968
	if(vehicle _this == _this) exitWith {false};

	private ["_veh", "_cfg", "_trts", "_return", "_trt"];
	_veh = (vehicle _this);
	_cfg = configFile >> "CfgVehicles" >> typeOf(_veh);
	_trts = _cfg >> "turrets";
	_return = false;

	for "_i" from 0 to (count _trts - 1) do {
		_trt = _trts select _i;

		if(getNumber(_trt >> "iscopilot") == 1) exitWith {
			_return = (_veh turretUnit [_i] == _this);
		};
	};

	_return
};

fnc_cmCount = {
	private _cmcount = 0;
	{_cmcount = _cmcount + (_x select 1)} forEach (magazinesAmmo vehicle player);
	_cmcount
};

fnc_getCurrentCamMode = {
	ISRCEWS_CAM_MODES select ISRCEWS_CAM_MODE_INDEX
};

fnc_getTempDescription = {
	private _desc = "NOMINAL";
	if (ISRCEWS_SYSTEM_HEAT >= ISRCEWS_OVERHEAT_THRESHOLD) then {
		_desc = "OVERHEAT";
	};
	if (ISRCEWS_SYSTEM_HEAT <= ISRCEWS_OVERHEAT_THRESHOLD * 0.75) then {
		_desc = "HI";
	};
	if (ISRCEWS_SYSTEM_HEAT <= ISRCEWS_OVERHEAT_THRESHOLD * 0.5) then {
		_desc = "MED";
	};
	if (ISRCEWS_SYSTEM_HEAT <= ISRCEWS_OVERHEAT_THRESHOLD * 0.25) then {
		_desc = "LOW";
	};
	format ["%1 | %2", _desc, ISRCEWS_SYSTEM_HEAT];
};

fnc_drawLine = {
	/*
	Author:
	rÃ¼be

	Description:
	draws a line on the map (with rect. area-markers)

	Parameter(s):
	_this: parameters (array of array [key (string), value (any)])

			- required:
				- "start" (position)
				- "end" (position)

			- optional:
				- "id" (unique marker string, default = RUBE_createMarkerID)
				- "color" (string, default = ColorBlack)
				- "size" (number, default = 5)

	Example:
	_marker = [
		["start", _pos],
		["end", _pos2],
		["color", "ColorRed"],
		["size", 24]
	] call RUBE_mapDrawLine; 

	Returns:
	marker
	*/

	private ["_mrk", "_start", "_end", "_color", "_size", "_id", "_dist", "_ang", "_center"];

	_mrk = "";

	_start = [0,0,0];
	_end = [0,0,0];

	_color = "ColorBlack";
	_size = 5;
	_id = "";

	// read parameters
	{
	switch (_x select 0) do
	{
		case "start": { _start = _x select 1; };
		case "end":   { _end   = _x select 1; };
		case "color": { _color = _x select 1; };
		case "size":  { _size  = _x select 1; };
		case "id":    
		{ 
			if ((typeName (_x select 1)) == "STRING") then
			{
			_id = _x select 1; 
			};
		};
	};
	} forEach _this;

	// calculate line
	_dist = sqrt(((_end select 0)-(_start select 0))^2+((_end select 1)-(_start select 1))^2) * 0.5;
	_ang = ((_end select 0)-(_start select 0)) atan2 ((_end select 1)-(_start select 1));
	_center = [(_start select 0)+sin(_ang)*_dist,(_start select 1)+cos(_ang)*_dist];

	// create marker
	if (_id == "") then
	{
		_id = format["isrcews_line_%1", [24] call fnc_genid];
	};
	_mrk = createMarker [_id, _center];

	// define marker
	_mrk setMarkerDir _ang;
	_mrk setMarkerPos _center;
	_mrk setMarkerShape "RECTANGLE";
	_mrk setMarkerBrush "SOLID";
	_mrk setMarkerColor _color;
	_mrk setMarkerSize [_size, _dist];

	// return marker
	_mrk
};