HCL_ENABLED = false;
[] spawn {

	// Ready/active marker (top) - 600m
	private _ready_marker = createMarker [format["hcl_marker_%1", [12] call fnc_genId], [0, 600, 0]];
	_ready_marker setMarkerColor "ColorGreen";
	_ready_marker setMarkerType "selector_selectable";
	_ready_marker setMarkerText "HCL: Active";
	_ready_marker setMarkerSize [0.5, 0.5];

	// FPS Marker - 400m
	private _fps_marker = createMarker [format["hcl_marker_%1", [13] call fnc_genId], [0, 400, 0]];
	_fps_marker setMarkerType "loc_download";
	_fps_marker setMarkerText "0 FPS";
	_fps_marker setMarkerColor "ColorRed";

	// Local Clients Marker
	private _lc_marker = createMarker [format["hcl_marker_%1", [13] call fnc_genId], [0, 200, 0]];
	_lc_marker setMarkerType "loc_Box";
	_lc_marker setMarkerText "Local Units: 0";
	_lc_marker setMarkerColor "ColorGreen";		

	while {true} do {

		// FPS Marker Update
		private _fps = diag_fps;
		if (_fps >= 20) then {
			_fps_marker setMarkerColor "ColorGreen";
		} else {
			if (_fps >= 10) then {
				_fps_marker setMarkerColor "ColorYellow";
			} else {
				_fps_marker setMarkerColor "ColorRed";
			}
		};
		_fps_marker setMarkerText format["HCL FPS: %1", floor(_fps / 1)];    

		// Local Clients Marker Update
		private _units = 0;
		{if (local _x) then {_units = _units + 1}} forEach allUnits;
		_lc_marker setMarkerText format["HCL Units: %1", _units];

		if (HCL_ENABLED) then {
			_ready_marker setMarkerColor "ColorGreen";
			_ready_marker setMarkerText "HCL: Active";
		} else {
			_ready_marker setMarkerColor "ColorYellow";
			_ready_marker setMarkerText "HCL: Inactive";
		};
		sleep 5;
	};
};

// Restart notifications
/*
[] spawn{
    
    private _thirtyMinutes = 30 * 60;
    private _fifteenMinutes = 15 * 60;

    // 4.5 hours
    sleep (RESTART_INTERVAL_SECONDS - _thirtyMinutes) - 70; // -70 to account for startup

    ["Intel", ["Server will restart in 30 minutes."]] remoteExec ["BIS_fnc_showNotification", -2];

    sleep _fifteenMinutes;

    ["Intel", ["Server will restart in 15 minutes."]] remoteExec ["BIS_fnc_showNotification", -2];

    sleep 10 * 60;

    ["Intel", ["Server will restart in 5 minutes!"]] remoteExec ["BIS_fnc_showNotification", -2];

    sleep 4 * 60;
    
    ["Intel", ["Server will restart in the next 60 seconds!"]] remoteExec ["BIS_fnc_showNotification", -2];

};
*/