
[] spawn {

	ISRC_CURRENT_OBJECT_MANIPULATED = cursorTarget;

	if (isNull ISRC_CURRENT_OBJECT_MANIPULATED) exitWith {
		ISRC_CURRENT_OBJECT_MANIPULATED = false;
	};

	waitUntil { !isNull (findDisplay 46) };
	
	disableSerialization; 
	ISRC_OBJECT_MANIPULATION__RSC__DISPLAY = findDisplay 46 createDisplay "RscDisplayEmpty"; 

	//ISRC_OBJECT_MANIPULATION__RSC__DISPLAY displaySetEventHandler ["onUnload", "ISRC_CURRENT_OBJECT_MANIPULATED = false;hint 'fart';"];

	private _ctrlGroup = ISRC_OBJECT_MANIPULATION__RSC__DISPLAY ctrlCreate ["RscControlsGroupNoScrollbars", -1]; 
	_ctrlGroup ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];		
	_ctrlGroup ctrlSetPosition [0.5 * (safeZoneW / 2), 0.4, 0.4 * (safeZoneH / 2), (0.2 * safeZoneW) / 4];
	_ctrlGroup ctrlCommit 0;		

	ISRC_OBJECT_MANIPULATION__RSC__DIRECTION = ISRC_OBJECT_MANIPULATION__RSC__DISPLAY ctrlCreate ["RscText", -1, _ctrlGroup];
	ISRC_OBJECT_MANIPULATION__RSC__DIRECTION ctrlSetPosition [0, 0, 0.45, 0.05];
	ISRC_OBJECT_MANIPULATION__RSC__DIRECTION ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
	ISRC_OBJECT_MANIPULATION__RSC__DIRECTION ctrlSetText format["Direction: %1", getDir ISRC_CURRENT_OBJECT_MANIPULATED];
	ISRC_OBJECT_MANIPULATION__RSC__DIRECTION ctrlCommit 0;

	ISRC_OBJECT_MANIPULATION__RSC__HEIGHT = ISRC_OBJECT_MANIPULATION__RSC__DISPLAY ctrlCreate ["RscText", -1, _ctrlGroup];
	ISRC_OBJECT_MANIPULATION__RSC__HEIGHT ctrlSetPosition [0, 0.05, 0.45, 0.05];
	ISRC_OBJECT_MANIPULATION__RSC__HEIGHT ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
	ISRC_OBJECT_MANIPULATION__RSC__HEIGHT ctrlSetText format["Height: %1m", getPos ISRC_CURRENT_OBJECT_MANIPULATED select 2];
	ISRC_OBJECT_MANIPULATION__RSC__HEIGHT ctrlCommit 0;		

	ISRC_OBJECT_MANIPULATION__RSC__POSX = ISRC_OBJECT_MANIPULATION__RSC__DISPLAY ctrlCreate ["RscText", -1, _ctrlGroup];
	ISRC_OBJECT_MANIPULATION__RSC__POSX ctrlSetPosition [0, 0.1, 0.45, 0.05];
	ISRC_OBJECT_MANIPULATION__RSC__POSX ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
	ISRC_OBJECT_MANIPULATION__RSC__POSX ctrlSetText format["Pos X: %1", getPos ISRC_CURRENT_OBJECT_MANIPULATED select 0];
	ISRC_OBJECT_MANIPULATION__RSC__POSX ctrlCommit 0;	

	ISRC_OBJECT_MANIPULATION__RSC__POSY = ISRC_OBJECT_MANIPULATION__RSC__DISPLAY ctrlCreate ["RscText", -1, _ctrlGroup];
	ISRC_OBJECT_MANIPULATION__RSC__POSY ctrlSetPosition [0, 0.15, 0.45, 0.05];
	ISRC_OBJECT_MANIPULATION__RSC__POSY ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
	ISRC_OBJECT_MANIPULATION__RSC__POSY ctrlSetText format["Pos Y: %1", getPos ISRC_CURRENT_OBJECT_MANIPULATED select 1];
	ISRC_OBJECT_MANIPULATION__RSC__POSY ctrlCommit 0;				

	private _ctrlSlider = ISRC_OBJECT_MANIPULATION__RSC__DISPLAY ctrlCreate ["RscSlider", 5, _ctrlGroup];
	_ctrlSlider sliderSetRange [0, 360];
	_ctrlSlider sliderSetSpeed [0.05 * 360, 0.05 * 360];
	_ctrlSlider sliderSetPosition getDir ISRC_CURRENT_OBJECT_MANIPULATED;
	_ctrlSlider ctrlSetPosition [0.2, 0, 0.2, 0.05]; /////////////////
	_ctrlSlider ctrlAddEventHandler ["SliderPosChanged", {
		params ["_ctrlSlider", "_value"];
		ISRC_CURRENT_OBJECT_MANIPULATED setDir _value;
		ISRC_OBJECT_MANIPULATION__RSC__DIRECTION ctrlSetText format["Direction: %1°", _value];
		[ISRC_CURRENT_OBJECT_MANIPULATED] call fnc_updateMovable;
	}];
	_ctrlSlider ctrlCommit 0;

	private _ctrlSlider2 = ISRC_OBJECT_MANIPULATION__RSC__DISPLAY ctrlCreate ["RscSlider", 7, _ctrlGroup];
	_ctrlSlider2 sliderSetRange [0, 100];
	_ctrlSlider2 sliderSetSpeed [0.05 * 100, 0.05 * 100];
	_ctrlSlider2 sliderSetPosition ((getPosATL ISRC_CURRENT_OBJECT_MANIPULATED) select 2);
	_ctrlSlider2 ctrlSetPosition [0.2, 0.05, 0.2, 0.05]; /////////////////
	_ctrlSlider2 ctrlAddEventHandler ["SliderPosChanged", {
		params ["_ctrlSlider2", "_value"];
		private _p = getPosATL ISRC_CURRENT_OBJECT_MANIPULATED;
		ISRC_CURRENT_OBJECT_MANIPULATED setPosATL [
			_p select 0,
			_p select 1,
			_value
		];
		ISRC_OBJECT_MANIPULATION__RSC__HEIGHT ctrlSetText format["Height: %1m", _value];
	}];
	_ctrlSlider2 ctrlCommit 0;

	private _ctrlSlider3 = ISRC_OBJECT_MANIPULATION__RSC__DISPLAY ctrlCreate ["RscSlider", -1, _ctrlGroup];
	private _px = getPosATL ISRC_CURRENT_OBJECT_MANIPULATED select 0;
	_ctrlSlider3 sliderSetRange [_px - 10, _px + 10];
	_ctrlSlider3 sliderSetSpeed [0.05 * 20, 0.05 * 20];
	_ctrlSlider3 sliderSetPosition (getPos ISRC_CURRENT_OBJECT_MANIPULATED select 0);
	_ctrlSlider3 ctrlSetPosition [0.2, 0.1, 0.2, 0.05]; /////////////////
	_ctrlSlider3 ctrlAddEventHandler ["SliderPosChanged", {
		params ["_ctrlSlider3", "_value"];
		private _p = getPosATL ISRC_CURRENT_OBJECT_MANIPULATED;
		ISRC_CURRENT_OBJECT_MANIPULATED setPosATL [
			_value,
			_p select 1,
			_p select 2
		];
		ISRC_OBJECT_MANIPULATION__RSC__POSX ctrlSetText format["Pos X: %1", _value];
		[ISRC_CURRENT_OBJECT_MANIPULATED] call fnc_updateMovable;
	}];
	_ctrlSlider3 ctrlCommit 0;

	private _ctrlSlider4 = ISRC_OBJECT_MANIPULATION__RSC__DISPLAY ctrlCreate ["RscSlider", -1, _ctrlGroup];
	private _py = getPosATL ISRC_CURRENT_OBJECT_MANIPULATED select 1;
	_ctrlSlider4 sliderSetRange [_py - 10, _py + 10];
	_ctrlSlider4 sliderSetSpeed [0.05 * 20, 0.05 * 20];
	_ctrlSlider4 sliderSetPosition (getPos ISRC_CURRENT_OBJECT_MANIPULATED select 1);
	_ctrlSlider4 ctrlSetPosition [0.2, 0.15, 0.2, 0.05]; /////////////////
	_ctrlSlider4 ctrlAddEventHandler ["SliderPosChanged", {
		params ["_ctrlSlider4", "_value"];
		private _p = getPosATL ISRC_CURRENT_OBJECT_MANIPULATED;
		ISRC_CURRENT_OBJECT_MANIPULATED setPosATL [
			_p select 0,
			_value,
			_p select 2
		];
		ISRC_OBJECT_MANIPULATION__RSC__POSY ctrlSetText format["Pos Y: %1", _value];
		[ISRC_CURRENT_OBJECT_MANIPULATED] call fnc_updateMovable;
	}];
	_ctrlSlider4 ctrlCommit 0;		

	ISRC_OBJECT_MANIPULATION__RSC__INFO_OBJECT = ISRC_OBJECT_MANIPULATION__RSC__DISPLAY ctrlCreate ["RscText", -1, _ctrlGroup];
	ISRC_OBJECT_MANIPULATION__RSC__INFO_OBJECT ctrlSetPosition [0, 0.21, 0.45, 0.05];
	ISRC_OBJECT_MANIPULATION__RSC__INFO_OBJECT ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
	ISRC_OBJECT_MANIPULATION__RSC__INFO_OBJECT ctrlSetText format["Object: %1", typeOf ISRC_CURRENT_OBJECT_MANIPULATED];
	ISRC_OBJECT_MANIPULATION__RSC__INFO_OBJECT ctrlCommit 0;		

/*
	ISRC_OBJECT_MANIPULATION__RSC__INFO_FPS = ISRC_OBJECT_MANIPULATION__RSC__DISPLAY ctrlCreate ["RscText", -1, _ctrlGroup];
	ISRC_OBJECT_MANIPULATION__RSC__INFO_FPS ctrlSetPosition [0, 0.51, 0.45, 0.05];
	ISRC_OBJECT_MANIPULATION__RSC__INFO_FPS ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
	ISRC_OBJECT_MANIPULATION__RSC__INFO_FPS ctrlSetText format["FPS: %1 ", diag_fps];
	ISRC_OBJECT_MANIPULATION__RSC__INFO_FPS ctrlCommit 0;	
*/
	
/*

	private _cancel = ISRC_OBJECT_MANIPULATION__RSC__DISPLAY ctrlCreate ["RscShortcutButton", 8, _ctrlGroup]; 
	_cancel ctrlSetPosition [0.25, 0.75, 0.25, 0.05]; 
	_cancel ctrlCommit 0; 
	_cancel ctrlSetText " OK "; 
	_cancel ctrlAddEventHandler ["ButtonClick", {
		params ["_ctrl"]; 
		//ISRC_OBJECT_MANIPULATION__RSC__DISPLAY displayRemoveEventHandler ["KeyDown", _keyDown];
		ISRC_OBJECT_MANIPULATION__RSC__DISPLAY closeDisplay 1;
		ISRC_CURRENT_OBJECT_MANIPULATED = false;
	}]; 
*/
	_ctrlGroup ctrlSetPosition [0.25, 0.25, 0.5, 0.5]; 
	_ctrlGroup ctrlCommit 0.1; 
	//playSound "Hint3";


	
/*
	_keyDown = (findDisplay 46) displayAddEventHandler ["KeyDown", {
		params ["_control", "_dikCode", "_shift", "_ctrl", "_alt"];
		private _handled = false;
		if (_dikCode == 1) then {
			ISRC_OBJECT_MANIPULATION__RSC__DISPLAY displayRemoveEventHandler ["KeyDown", _keyDown];
			_handled = true;
			ISRC_OBJECT_MANIPULATION__RSC__DISPLAY closeDisplay 1;
			ISRC_CURRENT_OBJECT_MANIPULATED = false;
			
		};
		_handled
	}];
	[] spawn {
		while {typeName ISRC_CURRENT_OBJECT_MANIPULATED != "BOOL"} do {
			ISRC_OBJECT_MANIPULATION__RSC__INFO_FPS ctrlSetText format["FPS: %1 ", diag_fps];
			//drawLine3D [ASLToAGL getPos player, ASLToAGL getPos ISRC_CURRENT_OBJECT_MANIPULATED, [1,0,0,1]];
			sleep(0.1);
		};
		systemChat "Exiting OBJ MAN... ISRC_CURRENT_OBJECT_MANIPULATED=false";
	};
*/
};
