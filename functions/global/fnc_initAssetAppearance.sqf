params["_vehicle"];
private _type = typeOf _vehicle;
if ("ammo" in _type) then {
	[_vehicle, 100] call ace_rearm_fnc_makeSource;
};
if ("repair" in _type) then {
	_vehicle setVariable ["ACE_isRepairVehicle", true];
};            
if ("RHSGREF_A29B_HIDF" == _type) then {
	[_vehicle, "Standard"] call BIS_fnc_initVehicle;
};
if ("rhsusf_m1165a1_gmv_m134d_m240_socom_d" == _type) then {
	[_vehicle, "rhs_sofwoodland"] call BIS_fnc_initVehicle;
};
if ("USAF_F35A_LIGHT" == _type) then {
	[_vehicle, "TestColors"] call BIS_fnc_initVehicle;
};
if ("USAF_A10" == _type) then {
	[_vehicle, "Base_Grey_Hog_Worn"] call BIS_fnc_initVehicle;
};
if ("fza_ah64d_b2e" == _type) then {
	[_vehicle, "arb229th_weather"] call BIS_fnc_initVehicle;
};
if ("SuperAV_RSOP" == _type) then {
	[
		_vehicle,
		["USMCForestCamo",1], 
		["showBags",1,"showCamonetHull",1,"showCamonetTurret",1,"showSLATHull",1,"showSLATTurret",1]
	] call BIS_fnc_initVehicle;
};
if ("RHS_MELB_MH6M" == _type) then {
	[
		_vehicle,
		nil,
		["AddBobhead",1,"hide_NoFear",1,"hide_SGDM",0,"hide_SN_nose",0,"hide_clan",1]
	] call BIS_fnc_initVehicle;
};
if ("RHS_MELB_AH6M" == _type) then {
	[
		_vehicle,
		nil,
		["AddBobhead",1,"hide_NoFear",1,"hide_SGDM",0,"hide_SN_nose",0,"hide_clan",1]
	] call BIS_fnc_initVehicle;
}; 

