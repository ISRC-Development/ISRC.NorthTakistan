params ["_newUnit", "_oldUnit", "_respawn", "_respawnDelay"];

// Remove old scroll actions
removeAllActions _oldUnit;

call fnc_init_addaction_manager;

showScoretable 0;
setCurrentChannel 0; // This might be an issue???

[_newUnit] call fnc_applyAddactions;

player setPos RESPAWN_LOCATION;

_name     = name _newUnit;
_groupId  = groupId group _newUnit;
_roledesc = roleDescription _newUnit;

if ("Zeus" in _roledesc) then { // Working ????
	_newUnit setUnitLoadout [[],[],["rhsusf_weap_m9","","","",["rhsusf_mag_15Rnd_9x19_FMJ",15],[],""],["rds_uniform_priest",[]],[],[],"","",["ACE_Vector","","","",[],[],""],["ItemMap","ItemcTab","TFAR_anprc152_2","ItemCompass","ItemWatch",""]];
} else {
	if ("Commander" in _roledesc) then {
		_newUnit setUnitLoadout [[],[],["rhsusf_weap_m9","","","",["rhsusf_mag_15Rnd_9x19_FMJ",15],[],""],["U_B_ParadeUniform_01_US_decorated_F",[]],[],[],"","",["ACE_Vector","","","",[],[],""],["ItemMap","ItemcTab","TFAR_anprc152_2","ItemCompass","ItemWatch",""]];
	} else {
		_newUnit setUnitLoadout [[],[],["rhsusf_weap_m9","","","",["rhsusf_mag_15Rnd_9x19_FMJ",15],[],""],["U_C_Poloshirt_blue",[]],[],[],"H_Cap_blk","",["ACE_Vector","","","",[],[],""],["ItemMap","ItemcTab","TFAR_anprc152_2","ItemCompass","ItemWatch",""]];
	};
};

// Assign TFAR radio
_newUnit linkItem "TFAR_anprc152";

// Apply actions to player if doesnt have actions.
if !(HAS_ACTIONS) then 
{
	call fnc_applyActions;	
};	 

if ((_newUnit getVariable["has_seen_intro", false]) == false) then
{
	// OLD INTRO LOCATION
	_newUnit setVariable["has_seen_intro", true];	
};	

// Testing bands mod
/*
private _band = createSimpleObject [getMissionPath "temp\armband_base_done", getPos player];
_band setObjectTexture [0, "isrc_texturepack\isrc.paa"];
_band attachTo [player, getPos player, "rightarmroll", true];
*/
// Wearables mod? https://sketchfab.com/3d-models/revault-with-steel-band-and-charger-a081fe7c8a0e440b84287ff7ef8acd83



/*
 
private _tank = createSimpleObject [getMissionPath "brahmos_texturized_x10.p3d", getPosASLW player]; 
for "_i" from 0 to 10 do {
	_tank setObjectTexture [_i, "#(rgb,8,8,3)color(1,0,0,1)"]; 
};

_tank setVectorDirAndUp [getDir player, [0,0,1]];

_tank 
*/


/*

test_turret = "O_SAM_System_04_F" createVehicle (getPos player vectorAdd [1, 1, 1]);
createVehicleCrew test_turret;

test_turret addWeaponTurret [0, [0]];

test_turret addWeaponTurret ["gbs_weapon_s750Launcher", [0]];
test_turret addMagazineTurret ["gbs_magazine_Missile_s750_x4", [0], 1];

systemChat format ["%1", test_turret weaponsTurret [0]];

*/
