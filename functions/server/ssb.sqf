/*

  Slower more deliberate tracking and attacking script
  
  Arguments
    1, Group or object tracker  [Object or Group]
    2, Range of tracking        [Number]
*/


// functions ---

_fn_findTarget = {
    _newDist = _range; 
    _all = (switchableUnits + playableUnits - entities "HeadlessClient_F");
    _all = _all select {side _x != civilian && {side _x != side _group}};
    _target = objNull;
    {
        _distance = (leader _group) distance2d _x;
        if (_distance < _newDist && {getpos _x select 2 < 200}) then {
			_target  = _x;
			_newDist = _distance;
		};
        true
    } count _all; 
    _target
};

// functions end ---

// init
params ["_group",["_range",800],["_cycle", 1 + selectRandom [30, 25, 20, 40, 15]],["_alreadydetonated", false]];

_male_audio   = [
    ["malescream1", 3],
    ["malescream2", 2]
];

_female_audio = [
    ["femalescream1", 2],
    ["femalescream2", 1]	
];

// sort grp
if (!local _group) exitWith {};
if (_group isEqualType objNull) then {_group = group _group;};

{
    _x addGoggles "G_Balaclava_blk";
    _x addVest    "V_TacVest_oli";
} forEach units _group;

// orders
//_group setbehaviour "COMBAT";
_group setSpeedMode "FULL";

// Hunting loop
while {{alive _x} count units _group > 0} do {

    // performance
    waitUntil {sleep 1;simulationenabled leader _group};

    // settings 
    _combat = behaviour leader _group isEqualTo "COMBAT";
    _onFoot = (isNull objectParent (leader _group));

    // find
    _target = call _fn_findTarget;

    // orders
    if (!isNull _target) then {
        _group move (getPos _target);
        _group setFormDir (leader _group getRelDir _target);
        _group setSpeedMode "FULL";
        //systemChat format ["%1,  Tracking target %2 @ %3...", getPos leader _group, name leader group _target, getPos _target];
		_lastpos = getpos leader _group;
		if (leader _group distance2D _target <= 25) then
        {
            private _ssb = leader _group;
            if !(getPos _ssb isEqualTo [0, 0, 0]) then 
            {
                private _audio  = selectRandom (if (typeOf _ssb == "ZEPHIK_Female_Civ_12") then { _female_audio } else { _male_audio });
                [leader _group, true] remoteExec ["setRandomLip"];// Move Mouth
				[leader _group, 0.9] remoteExec ["setFaceAnimation"];// Open eyes wide
				[leader _group, [_audio select 0, 100]] remoteExec ["say"];
                //systemChat format["Saying %1", _audio select 0];
                
                private _explosion_vehicle = (selectRandom["Bo_GBU12_LGB", "DemoCharge_Remote_Ammo_Scripted",  "DemoCharge_Remote_Ammo_Scripted"]) createVehicle (getPos _ssb);
                _explosion_vehicle setDamage 1;
                
                _alreadydetonated = true;

                if (vehicle _ssb != _ssb) then {
                    deleteVehicle (vehicle _ssb);
                };
                
                deleteVehicle _ssb;
            };
        };
    };
	//systemChat format ["Moving Cycle... (%1 Seconds)", _cycle];

    // WAIT FOR IT!
    sleep _cycle;
	
};


if !(_alreadydetonated) then {
    private _ssb = leader _group;
    if !(getPos _ssb isEqualTo [0, 0, 0]) then {
        null = 'Bo_GBU12_LGB' createVehicle (getPos leader _group);       
        //systemChat format ["Detonation: Deadman's Switch"];  
    };
};



