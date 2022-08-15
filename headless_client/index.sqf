fnc_getPlayersMeanPos = {
    private _pos     = false;
	private _players = [];
	private _ppx     = [];
	private _ppy     = [];
	
	private _ppx_am  = 0;
	private _ppy_am  = 0;

	{
        if (typeOf _x != "HeadlessClient_F") then {
            _players pushBack _x;
            _ppx pushBack ((getPos _x) select 0);
            _ppy pushBack ((getPos _x) select 1);
	    }
    } forEach allPlayers;
	_ppx_am =  ([_ppx] call fnc_sum) / count _ppx;
	_ppy_am = ([_ppy] call fnc_sum) / count _ppy;

	if (count _players > 0) then {
        _pos = [_ppx_am, _ppy_am, 0];
    };
    _pos
};

call compileFinal preprocessFileLineNumbers "headless_client\job.sqf";
if (!hasInterface && !isServer) then {
	[] call compileFinal preprocessFileLineNumbers "headless_client\daemon.sqf";
};