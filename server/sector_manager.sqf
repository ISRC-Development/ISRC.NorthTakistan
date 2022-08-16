fnc_activate_sector = {
	
	params ["_trigger"];
	
	private _location_meta = _trigger getVariable ["location_meta", false];
	private _poiName 	   = _location_meta select 0; // POI Name              - String - name of the POI to show
	private _pos           = _location_meta select 1; // POI Position          - Array  - [x,y,z] 
	private _locationType  = _location_meta select 2; // POI Type              - String - type of the POI
	private _locationUID   = _location_meta select 3; // POI UID               - String - unique ID of the POI
	private _locationMarker= _location_meta select 4; // POI Marker            - String - marker of the POI	

	// delete the trigger since we no longer need it/
	deleteVehicle _trigger;

	// Set Sector active
	ACTIVE_SECTORS = ACTIVE_SECTORS + [_poiName];

	["Intel", [format ["%1 is active!", _poiName]]] remoteExec ["BIS_fnc_showNotification"];
};

fnc_deactivate_sector = {

	params ["_poiName", "_locationType", "_triggerpos"];

	// Set Sector inactive
	ACTIVE_SECTORS = ACTIVE_SECTORS - [_poiName];

	// Add to captured sectors 
	private _savedCaptures = profileNamespace getVariable ["CAPTURED_SECTORS", []];
	// Saves persistent array of names of sectors we've captured.
	if !(_poiName in _savedCaptures) then {
		_savedCaptures = _savedCaptures + [_poiName];
		profileNamespace setVariable ["CAPTURED_SECTORS", _savedCaptures];
		saveprofilenamespace;
	};

	// Saves our new funding.
	private _currentFunding = call fnc_getCurrentFundingBalance;

	private _newFunding = 500000;
	private _supplyAmount = 0;
	private _supplyRange  = 70;
	switch (_locationType) do {
		case "NameVillage": {
			_newFunding = 1000000;
		};
		case "NameLocal": {
			_newFunding = 2000000;
			_supplyAmount = 0;
			_supplyRange = 80;
		};
		case "NameCity": {
			_newFunding = 5000000;
			_supplyAmount = 0;
			_supplyRange = 125;
		};
		case "NameCityCapital": {
			_newFunding = 10000000;
			_supplyAmount = 0;
			_supplyRange = 175;
		};
		default {};
	};

	// Get paid
	[_newFunding] call fnc_addToFunding;	

	// Spawn Supplies
	for "_i" from 0 to _supplyAmount do {
		private _supply = (selectRandom (call fnc_getAllSuppllyClasses)) createVehicle ([[[_triggerpos, 100]], []] call BIS_fnc_randomPos);
		_supply allowDamage false;
		_supply setVariable ["IS_PROP", true];
		[_supply] call fnc_cleanVehicle;
	};		

	["IntelGreen", [format ["We have captured %1!", _poiName]]] remoteExec ["BIS_fnc_showNotification"];
	sleep 2;
	["IntelGreen", [format ["New Funding: <br/>$%1", [_newFunding] call fnc_standardNotation]]] remoteExec ["BIS_fnc_showNotification"];

};