
ISRCEWS_CAM_MODE_INDEX    = 0;
ISRCEWS_MENU_OPEN         = true;
ISRCEWS_SHOW_MAP 		  = true;
ISRCEWS_CAMERA_TARGET     = getPos player;

if (typeName ISRCEWS_CAMERA_LOCAL != "BOOL") then {
	ISRCEWS_CAMERA_LOCAL cameraEffect ["terminate","back"];
	camDestroy ISRCEWS_CAMERA_LOCAL;
};
// INIT CAMERA
ISRCEWS_CAMERA_LOCAL = "camera" camCreate [position vehicle player select 0, position vehicle player select 1, 2];
ISRCEWS_CAMERA_LOCAL attachTo [vehicle player, [0,0,0]];
ISRCEWS_CAMERA_LOCAL cameraEffect ["internal","back","rtt"];
"rtt" setPiPEffect [call fnc_getCurrentCamMode select 0];
ISRCEWS_CAMERA_ZOOM = 0.75;
ISRCEWS_CAMERA_LOCAL camSetTarget ISRCEWS_CAMERA_TARGET; 
ISRCEWS_CAMERA_LOCAL camSetFov ISRCEWS_CAMERA_ZOOM;
//ISRCEWS_CAMERA_LOCAL camSetFocus [50, 1];
ISRCEWS_CAMERA_LOCAL camCommit 0;


// waitUntil { camCommitted ISRCEWS_CAMERA_LOCAL; };

//ISRCEWS_CAMERA_LOCAL setVectorUp surfaceNormal position ISRCEWS_CAMERA_LOCAL;

disableSerialization; 
private _display = findDisplay 46 createDisplay "RscDisplayEmpty"; 

private _ctrlGroup = _display ctrlCreate ["RscControlsGroup", -1]; 
_ctrlGroup ctrlSetPosition [0, 0, 1, 1]; 
_ctrlGroup ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
_ctrlGroup ctrlCommit 0;

ISRCEWS_RSC_CAM_DISPLAY = _display ctrlCreate ["RscPicture", -1];
ISRCEWS_RSC_CAM_DISPLAY ctrlSetText "#(argb,512,512,1)r2t(rtt,1.0)";
ISRCEWS_RSC_CAM_DISPLAY ctrlSetPosition [0, 0, 1, 1];
ISRCEWS_RSC_CAM_DISPLAY ctrlCommit 0;
ISRCEWS_RSC_CAM_DISPLAY ctrlAddEventHandler ["Destroy", ISRCEWS_RSC_eh_onDestroy];

private _jam = _display ctrlCreate ["RscShortcutButton", -1, ISRCEWS_RSC_CAM_DISPLAY]; 
_jam ctrlSetPosition [0, 0, 0.25, 0.05]; 
_jam ctrlCommit 0; 
_jam ctrlSetTooltip format["Jam detected radar threats within %1m radius (3-Dimensional).", ISRCEWS_ENGAGEMENT_RADIUS];
_jam ctrlSetText " ANTI-RADAR EWS "; 
_jam ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
_jam ctrlAddEventHandler ["ButtonClick", {
	params ["_ctrl"]; 
	call ISRCEWS_fnc_startJammer;
}]; 

private _flares = _display ctrlCreate ["RscShortcutButton", -1, ISRCEWS_RSC_CAM_DISPLAY]; 
_flares ctrlSetPosition [0.25, 0, 0.25, 0.05]; 
_flares ctrlCommit 0; 
_flares ctrlSetText " STAND-OFF CHAFF "; 
_flares ctrlSetTooltip "CO-PILOT ONLY";
_flares ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
_flares ctrlAddEventHandler ["ButtonClick", {
	params ["_ctrl"]; 
	[6, 0.75] call ISRCEWS_fnc_pop_chaff;
	// params[["_pos", getPos player], ["_enemy_side", EAST], ["_range", 1000], ["_time", 10]];
	[
		getPos vehicle player,
		EAST,
		ISRCEWS_ENGAGEMENT_RADIUS/4,
		5
	] call ISRCEWS_obstructCrewVisionAndIRAndLaser;
}]; 

private _tglMap = _display ctrlCreate ["RscShortcutButton", -1, ISRCEWS_RSC_CAM_DISPLAY]; 
_tglMap ctrlSetPosition [0.5, 0, 0.125, 0.05]; 
_tglMap ctrlCommit 0; 
_tglMap ctrlSetText "MAP"; 
_tglMap ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
_tglMap ctrlAddEventHandler ["ButtonClick", {
	params ["_ctrl"]; 
	ISRCEWS_SHOW_MAP = !ISRCEWS_SHOW_MAP;
	ISRCEWS_MAP_PREVIEW ctrlShow ISRCEWS_SHOW_MAP;
}]; 

private _slewCam = _display ctrlCreate ["RscShortcutButton", -1, ISRCEWS_RSC_CAM_DISPLAY];
_slewCam ctrlSetPosition [0.625, 0, 0.125, 0.05];
_slewCam ctrlCommit 0;
_slewCam ctrlSetText "SLEW";
_slewCam ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
_slewCam ctrlAddEventHandler ["ButtonClick", {
	params ["_ctrl"];
	ISRCEWS_RSC_SLEW ctrlSetText "SLEW: INPUT";
	player onMapSingleClick {

		if (typeName ISRCEWS_CAMERA_LOCAL != "BOOL") then {
			ISRCEWS_CAMERA_LOCAL cameraEffect ["terminate","back"];
			camDestroy ISRCEWS_CAMERA_LOCAL;
		};		

		ISRCEWS_CAMERA_TARGET = _pos;

		ISRCEWS_CAMERA_LOCAL = "camera" camCreate [position vehicle player select 0, position vehicle player select 1, 2];
		ISRCEWS_CAMERA_LOCAL attachTo [vehicle player, [0,0,0]];
		ISRCEWS_CAMERA_LOCAL cameraEffect ["internal","back","rtt"];
		"rtt" setPiPEffect [call fnc_getCurrentCamMode select 0];
		ISRCEWS_CAMERA_LOCAL camSetTarget ISRCEWS_CAMERA_TARGET; 
		ISRCEWS_CAMERA_LOCAL camSetFov ISRCEWS_CAMERA_ZOOM;
		//ISRCEWS_CAMERA_LOCAL camSetFocus [50, 1];
		ISRCEWS_CAMERA_LOCAL camCommit 0;
		// waitUntil { camCommitted ISRCEWS_CAMERA_LOCAL; };

		ISRCEWS_RSC_SLEW ctrlSetText "SLEW: ACTIVE";
		onMapSingleClick '';

		systemChat format ["Slewed camera to %1", mapGridPosition _pos];
		systemChat format["%1", _pos];
		true
	};
}];

private _camModeTgl = _display ctrlCreate ["RscShortcutButton", -1, ISRCEWS_RSC_CAM_DISPLAY]; 
_camModeTgl ctrlSetPosition [0.75, 0, 0.125, 0.05]; 
_camModeTgl ctrlCommit 0; 
_camModeTgl ctrlSetText "MODE"; 
_camModeTgl ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
_camModeTgl ctrlAddEventHandler ["ButtonClick", {
	params ["_ctrl"]; 
	if (ISRCEWS_CAM_MODE_INDEX == (count ISRCEWS_CAM_MODES) - 1) then {
		ISRCEWS_CAM_MODE_INDEX = 0;
	} else {
		ISRCEWS_CAM_MODE_INDEX = ISRCEWS_CAM_MODE_INDEX + 1;
	};
	"rtt" setPiPEffect [call fnc_getCurrentCamMode select 0];
}];

private _zoomIn = _display ctrlCreate ["RscShortcutButton", -1, ISRCEWS_RSC_CAM_DISPLAY]; 
_zoomIn ctrlSetPosition [0.875, 0, 0.0625, 0.05];
_zoomIn ctrlCommit 0; 
_zoomIn ctrlSetText "+"; 
_zoomIn ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
_zoomIn ctrlAddEventHandler ["ButtonClick", {
	params ["_ctrl"]; 
	ISRCEWS_CAMERA_ZOOM = ISRCEWS_CAMERA_ZOOM - 0.05;
	if (ISRCEWS_CAMERA_ZOOM < 0) then {
		ISRCEWS_CAMERA_ZOOM = 0;
	} else {

		if (typeName ISRCEWS_CAMERA_LOCAL != "BOOL") then {
			ISRCEWS_CAMERA_LOCAL cameraEffect ["terminate","back"];
			camDestroy ISRCEWS_CAMERA_LOCAL;
		};		

		// INIT CAMERA
		ISRCEWS_CAMERA_LOCAL = "camera" camCreate [position vehicle player select 0, position vehicle player select 1, 2];
		ISRCEWS_CAMERA_LOCAL attachTo [vehicle player, [0,0,0]];
		ISRCEWS_CAMERA_LOCAL cameraEffect ["internal","back","rtt"];
		"rtt" setPiPEffect [call fnc_getCurrentCamMode select 0];		
		ISRCEWS_CAMERA_LOCAL camSetFov ISRCEWS_CAMERA_ZOOM;
		ISRCEWS_CAMERA_LOCAL camSetTarget ISRCEWS_CAMERA_TARGET; 
		//ISRCEWS_CAMERA_LOCAL camSetFocus [50, 1];
		ISRCEWS_CAMERA_LOCAL camCommit 0;
		//systemChat format["Zoom: %1", ISRCEWS_CAMERA_ZOOM];
	};
}]; 

private _zoomOut = _display ctrlCreate ["RscShortcutButton", -1, ISRCEWS_RSC_CAM_DISPLAY]; 
_zoomOut ctrlSetPosition [0.935, 0, 0.064, 0.05];
_zoomOut ctrlCommit 0; 
_zoomOut ctrlSetText "-"; 
_zoomOut ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
_zoomOut ctrlAddEventHandler ["ButtonClick", {
	params ["_ctrl"]; 
	ISRCEWS_CAMERA_ZOOM = ISRCEWS_CAMERA_ZOOM + 0.05;
	if (ISRCEWS_CAMERA_ZOOM > 0.75) then {
		ISRCEWS_CAMERA_ZOOM = 0.75;
	} else {

		if (typeName ISRCEWS_CAMERA_LOCAL != "BOOL") then {
			ISRCEWS_CAMERA_LOCAL cameraEffect ["terminate","back"];
			camDestroy ISRCEWS_CAMERA_LOCAL;
		};		

		// INIT CAMERA
		ISRCEWS_CAMERA_LOCAL = "camera" camCreate [position vehicle player select 0, position vehicle player select 1, 2];
		ISRCEWS_CAMERA_LOCAL attachTo [vehicle player, [0,0,0]];
		ISRCEWS_CAMERA_LOCAL cameraEffect ["internal","back","rtt"];
		"rtt" setPiPEffect [call fnc_getCurrentCamMode select 0];		
		ISRCEWS_CAMERA_LOCAL camSetFov ISRCEWS_CAMERA_ZOOM;
		ISRCEWS_CAMERA_LOCAL camSetTarget ISRCEWS_CAMERA_TARGET; 
		//ISRCEWS_CAMERA_LOCAL camSetFocus [50, 1];
		ISRCEWS_CAMERA_LOCAL camCommit 0;
		//systemChat format["Zoom: %1", ISRCEWS_CAMERA_ZOOM];
	};
}]; 

private _markerFlareWhite = _display ctrlCreate ["RscShortcutButton", -1, ISRCEWS_RSC_CAM_DISPLAY];
/// bottom left
_markerFlareWhite ctrlSetPosition [0, 0.95, 0.125, 0.05];
_markerFlareWhite ctrlSetBackgroundColor [1,1,1,1];
_markerFlareWhite ctrlCommit 0;
_markerFlareWhite ctrlSetText "FLR-WHT";
_markerFlareWhite ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
_markerFlareWhite ctrlAddEventHandler ["ButtonClick", {
	["White"] call ISRCEWS_fnc_markerFlare;
}];

private _markerFlareRed = _display ctrlCreate ["RscShortcutButton", -1, ISRCEWS_RSC_CAM_DISPLAY];
/// bottom left
_markerFlareRed ctrlSetPosition [0.125, 0.95, 0.125, 0.05];
_markerFlareRed ctrlSetBackgroundColor [1,1,1,1];
_markerFlareRed ctrlCommit 0;
_markerFlareRed ctrlSetText "FLR-RED";
_markerFlareRed ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
_markerFlareRed ctrlAddEventHandler ["ButtonClick", {
	["Red"] call ISRCEWS_fnc_markerFlare;
}];

private _markerFlareGreen = _display ctrlCreate ["RscShortcutButton", -1, ISRCEWS_RSC_CAM_DISPLAY];
/// bottom left
_markerFlareGreen ctrlSetPosition [0.125 * 2, 0.95, 0.125, 0.05];
_markerFlareGreen ctrlSetBackgroundColor [1,1,1,1];
_markerFlareGreen ctrlCommit 0;
_markerFlareGreen ctrlSetText "FLR-GRN";
_markerFlareGreen ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
_markerFlareGreen ctrlAddEventHandler ["ButtonClick", {
	["Green"] call ISRCEWS_fnc_markerFlare;
}];

private _markerFlareYellow = _display ctrlCreate ["RscShortcutButton", -1, ISRCEWS_RSC_CAM_DISPLAY];
/// bottom left
_markerFlareYellow ctrlSetPosition [0.125 * 3, 0.95, 0.125, 0.05];
_markerFlareYellow ctrlSetBackgroundColor [1,1,1,1];
_markerFlareYellow ctrlCommit 0;
_markerFlareYellow ctrlSetText "FLR-YLW";
_markerFlareYellow ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
_markerFlareYellow ctrlAddEventHandler ["ButtonClick", {
	["Yellow"] call ISRCEWS_fnc_markerFlare;
}];

private _markerFlareIR = _display ctrlCreate ["RscShortcutButton", -1, ISRCEWS_RSC_CAM_DISPLAY];
_markerFlareIR ctrlSetPosition [0.125 * 4, 0.95, 0.125, 0.05];
_markerFlareIR ctrlSetBackgroundColor [1,1,1,1];
_markerFlareIR ctrlCommit 0;
_markerFlareIR ctrlSetText "FLR-IR";
_markerFlareIR ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
_markerFlareIR ctrlAddEventHandler ["ButtonClick", {
	["CIR"] call ISRCEWS_fnc_markerFlare;
}];


ISRCEWS_MAP_PREVIEW = _display ctrlCreate ["RscMapControl", -1, ISRCEWS_RSC_CAM_DISPLAY];
// bottom-left
ISRCEWS_MAP_PREVIEW ctrlSetPosition [0.5, 0.05, 0.5, 0.5];
ISRCEWS_MAP_PREVIEW ctrlMapSetPosition [];
ISRCEWS_MAP_PREVIEW ctrlMapAnimAdd [0, 0.01, getPos player];
ctrlMapAnimCommit ISRCEWS_MAP_PREVIEW;
ISRCEWS_MAP_PREVIEW ctrlMapCursor ["", "3DEN"]; //<-- the actual usage
ISRCEWS_MAP_PREVIEW ctrlCommit 0; 

/*
// SIDE - CAM CONTROLS // 
private _left = _display ctrlCreate ["RscShortcutButton", -1, ISRCEWS_RSC_CAM_DISPLAY];
_left ctrlSetPosition [0, 0.8, 0.05, 0.05];
_left ctrlCommit 0;
_left ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
_left ctrlSetActiveColor [0.1, 0.1, 0.1, 1];
_left ctrlSetText "L ";
_left ctrlAddEventHandler ["ButtonClick", {
	params ["_ctrl"]; 
	ISRCEWS_CAMERA_LOCAL setVectorDir (vectorDir ISRCEWS_CAMERA_LOCAL vectorAdd [0, 0, 0.1]);
}];

private _right = _display ctrlCreate ["RscShortcutButton", -1, ISRCEWS_RSC_CAM_DISPLAY];
_right ctrlSetPosition [0.15, 0.8, 0.05, 0.05];
_right ctrlCommit 0;
_right ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
_right ctrlSetActiveColor [0.1, 0.1, 0.1, 1];
_right ctrlSetText "R ";
_right ctrlAddEventHandler ["ButtonClick", {
	params ["_ctrl"]; 
	ISRCEWS_CAMERA_LOCAL setVectorDir (vectorDir ISRCEWS_CAMERA_LOCAL vectorAdd [0, 0, -0.1]);
}];

private _up = _display ctrlCreate ["RscShortcutButton", -1, ISRCEWS_RSC_CAM_DISPLAY];
_up ctrlSetPosition [0.075, 0.75, 0.05, 0.05];
_up ctrlCommit 0;
_up ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
_up ctrlSetActiveColor [0.1, 0.1, 0.1, 1];
_up ctrlSetText "U ";
_up ctrlAddEventHandler ["ButtonClick", {
	params ["_ctrl"]; 
	// pan camera up
	ISRCEWS_CAMERA_LOCAL setVectorDir (vectorUp ISRCEWS_CAMERA_LOCAL vectorAdd [0, 0.1, 0]);
}];

private _down = _display ctrlCreate ["RscShortcutButton", -1, ISRCEWS_RSC_CAM_DISPLAY];
_down ctrlSetPosition [0.075, 0.85, 0.05, 0.05];
_down ctrlCommit 0;
_down ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
_down ctrlSetActiveColor [0.1, 0.1, 0.1, 1];
_down ctrlSetText "D ";
_down ctrlAddEventHandler ["ButtonClick", {
	params ["_ctrl"]; 
	// pan camera down
	ISRCEWS_CAMERA_LOCAL setVectorDir (vectorUp ISRCEWS_CAMERA_LOCAL vectorAdd [0, -0.1, 0]);
}];
*/

ISRCEWS_RSC_CM_COUNT = _display ctrlCreate ["RscText", -1, ISRCEWS_RSC_CAM_DISPLAY];
ISRCEWS_RSC_CM_COUNT ctrlSetPosition [0.75, 0.75, 0.25, 0.05];
ISRCEWS_RSC_CM_COUNT ctrlSetText format["CM: %1", call fnc_cmCount];
ISRCEWS_RSC_CM_COUNT ctrlCommit 0;

ISRCEWS_RSC_HEAT = _display ctrlCreate ["RscText", -1, ISRCEWS_RSC_CAM_DISPLAY];
ISRCEWS_RSC_HEAT ctrlSetPosition [0.75, 0.8, 0.25, 0.05];
ISRCEWS_RSC_HEAT ctrlSetText format["EWS TEMP: %1", ISRCEWS_SYSTEM_HEAT];
ISRCEWS_RSC_HEAT ctrlCommit 0;

ISRCEWS_RSC_MODE = _display ctrlCreate ["RscText", -1, ISRCEWS_RSC_CAM_DISPLAY];
ISRCEWS_RSC_MODE ctrlSetPosition [0.75, 0.85, 0.25, 0.05];
ISRCEWS_RSC_MODE ctrlSetText format["MODE: %1", call fnc_getCurrentCamMode select 1];
ISRCEWS_RSC_MODE ctrlCommit 0;

ISRCEWS_RSC_SLEW = _display ctrlCreate ["RscText", -1, ISRCEWS_RSC_CAM_DISPLAY];
ISRCEWS_RSC_SLEW ctrlSetPosition [0.75, 0.9, 0.25, 0.05];
ISRCEWS_RSC_SLEW ctrlSetText format["SLEW: %1", "NONE"];
ISRCEWS_RSC_SLEW ctrlCommit 0;

if (player == driver vehicle player) then {
	_jam ctrlEnable false;
	_flares ctrlEnable false;
};

if (call fnc_cmCount <= 0) then {
	_flares ctrlEnable false;
};

// Only copilot can use flares (for now)...
if !(player call fnc_isUnitCopilot) then {
	_flares ctrlEnable false;
};

_ctrlGroup ctrlSetPosition [0.25, 0.25, 0.5, 0.5]; 
_ctrlGroup ctrlCommit 0.1; 
//playSound "Hint3";

[] spawn {
	while {ISRCEWS_MENU_OPEN} do 
	{
		ISRCEWS_RSC_HEAT ctrlSetText format["EWS TEMP: %1", call fnc_getTempDescription];
		ISRCEWS_RSC_CM_COUNT ctrlSetText format["CM: %1", call fnc_cmCount];
		ISRCEWS_RSC_MODE ctrlSetText format["MODE: %1", call fnc_getCurrentCamMode select 1];
	};
};