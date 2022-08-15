fnc_getLogiSupplyHMAPbyClassName = {
	params["_classname"];
	private _result = false;
	{
		if ((LOGISTICS_SUPPLIES_CLASSES get _x) get "classname" == _classname) then {
			_result = LOGISTICS_SUPPLIES_CLASSES get _x;
		};
	} forEach LOGISTICS_SUPPLIES_CLASSES;
	_result
};

fnc_crateReciprocalNearbyAndStuffLOL = {
	
	private _nearby = false;
	{
		if (typeOf _x == "B_Slingload_01_Cargo_F") then {
			_nearby = true;
		};
	} forEach nearestObjects [player, [], 10];

	if (objectParent player != player) then {
		// Is in vehicle
		_nearby = false;
	};

	if !(alive player) then {
		// not alive
		_nearby = false;
	};
	
	_nearby	
};

fnc_getAllSuppllyClasses = {
	// Get all classNames of the know supply types
	private _supplyClassNames = [];
	{
		_supplyClassNames pushBack ((LOGISTICS_SUPPLIES_CLASSES get _x) get "classname");
	} forEach LOGISTICS_SUPPLIES_CLASSES;
	_supplyClassNames
};