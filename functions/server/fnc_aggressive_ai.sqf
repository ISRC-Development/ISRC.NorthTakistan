// File: fnc_aggressive_ai.sqf

fnc_aggressive_ai = {
	params["_group"];
	
	//_group setBehaviour "COMBAT";
	//_group setBehaviourStrong "COMBAT";
	_group allowFleeing 0; 
	_group setSpeedMode "FULL";
	_group enableAttack true;
	_group setCombatMode "RED";

	{
		_x setSkill ["general",        selectRandom[0.5, 0.65, 0.7]];
		_x setSkill ["courage",        selectRandom[0.65, 0.7, 0.75]];
		_x setSkill ["aimingAccuracy", selectRandom[0.1, 0.2]];
		_x setSkill ["aimingShake",    selectRandom[0.1, 0.2]];
		_x setSkill ["aimingSpeed",    selectRandom[0.1, 0.2]];
		_x setSkill ["commanding",     selectRandom[0.6, 0.7, 0.8]];
		_x setSkill ["spotDistance",   selectRandom[0.6, 0.7]];
		_x setSkill ["spotTime",       selectRandom[0.3, 0.4]];  
		_x setSkill ["reloadSpeed",    selectRandom[0.3, 0.4]]; 
		_x setUnitCombatMode "RED";
		_x setSkill selectRandom[0.3, 0.4, 0.5, 0.6];
	} forEach (units _group);	
};