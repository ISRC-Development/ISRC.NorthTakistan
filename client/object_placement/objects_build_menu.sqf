disableSerialization; 
private _display = findDisplay 46 createDisplay "RscDisplayEmpty"; 

PURCHASE_MENU_OPEN       = false;
PURCHASE_MENU_CART_ITEM = [];
CURRENT_FUNDING_BALANCE_BM = [missionNamespace, "CURRENT_FUNDING_BALANCE", 0] call BIS_fnc_getServerVariable;

ASSET_LISTBOX_POS = [0.25, 0, 0.5, 0.5];

ASSET_LISTBOX = _display ctrlCreate ["RscControlsGroupNoScrollbars", (count ISRC_BUILDABLE_OBJECTS) + 1];
ASSET_LISTBOX ctrlSetPosition ASSET_LISTBOX_POS;
ASSET_LISTBOX ctrlSetBackgroundColor [0.1,0.1,0.1,1];
ASSET_LISTBOX ctrlCommit 0;

ASSET_BG = _display ctrlCreate ["RscText", (count ISRC_BUILDABLE_OBJECTS), ASSET_LISTBOX];
ASSET_BG ctrlSetPosition [0, 0, 2, 0.25];
ASSET_BG ctrlSetBackgroundColor [0.1,0.1,0.1,1];
ASSET_BG ctrlCommit 0;

CURRENT_FUNDING_TEXT = _display ctrlCreate ["RscText", (count ISRC_BUILDABLE_OBJECTS) + 6, ASSET_LISTBOX];
CURRENT_FUNDING_TEXT ctrlSetPosition [0, 0];
CURRENT_FUNDING_TEXT ctrlSetText format["Funds: %1", [CURRENT_FUNDING_BALANCE_BM, true] call fnc_standardNumericalNotationString];
CURRENT_FUNDING_TEXT ctrlCommit 0;

ASSET_NAME = _display ctrlCreate ["RscText", (count ISRC_BUILDABLE_OBJECTS) + 2, ASSET_LISTBOX];
ASSET_NAME ctrlSetPosition [0, 0.05];
ASSET_NAME ctrlSetText "Object:";
ASSET_NAME ctrlCommit 0;

ASSET_PRICE = _display ctrlCreate ["RscText", (count ISRC_BUILDABLE_OBJECTS) + 3, ASSET_LISTBOX];
ASSET_PRICE ctrlSetPosition [0.25, 0];
ASSET_PRICE ctrlSetText "Price:";
ASSET_PRICE ctrlCommit 0;	

ASSET_PREVIEW = _display ctrlCreate ["RscPicture", 4444, ASSET_LISTBOX];
ASSET_PREVIEW ctrlSetPosition [0, 0.1];
ASSET_PREVIEW ctrlCommit 0;	

/*

ASSET_TYPE = _display ctrlCreate ["RscText", (count ISRC_BUILDABLE_OBJECTS) + 4, ASSET_LISTBOX];
ASSET_TYPE ctrlSetPosition ([ [-0.25,0.05, 0.01, 0], ASSET_LISTBOX_POS ] call BIS_fnc_vectorAdd);
ASSET_TYPE ctrlSetText "Class: ";
ASSET_TYPE ctrlCommit 0;
*/

private _ctrlGroup = _display ctrlCreate ["RscControlsGroup", -1]; 
_ctrlGroup ctrlCommit 0;

private _ctrlBackground = _display ctrlCreate ["RscTextMulti", -1, _ctrlGroup]; 	
_ctrlBackground ctrlSetPosition [0, 0, 0, 0]; 
_ctrlBackground ctrlSetBackgroundColor [0.1, 0.1, 0.1, 1];
_ctrlBackground ctrlEnable false; 
_ctrlBackground ctrlCommit 0; 

_groupDesc            = "N/A";
_group_index    	  = 0;
_control_id_index     = 0;
_control_height_index = 0;
_groupArray           = [];
{
	// Iterate all groups
	_groupDesc  = _x select 0;
	_groupArray = _x select 1;
	
	{
		// Iterate each asset in group
		private _thisAsset = _x;

		private _name  = _thisAsset select 0;
		private _class = _thisAsset select 1;
		private _price = _thisAsset select 2;
		
		private _ctrlEdit   = _display ctrlCreate ["RscButton", _control_id_index, _ctrlGroup]; 
		_ctrlEdit ctrlSetPosition [0, _control_height_index, 0.50, 0.05]; 	

		_ctrlEdit ctrlSetText format["[%1] - %2", _groupDesc, _thisAsset select 1];
		_ctrlEdit setVariable ["OPTION_DATA", _thisAsset];

		_ctrlEdit ctrlAddEventHandler ["ButtonClick", {
			params ["_control"];
			PURCHASE_MENU_CART_ITEM = _control getVariable ["OPTION_DATA", []];
			//hint format ["%1", PURCHASE_MENU_CART_ITEM];
			CURRENT_FUNDING_TEXT ctrlSetText format["Funds: %1", [CURRENT_FUNDING_BALANCE_BM, true] call fnc_standardNumericalNotationString];
			ASSET_NAME  ctrlSetText format["Object: %1", getText (configFile >> "CfgVehicles" >> (PURCHASE_MENU_CART_ITEM select 1) >> "displayName")];
			ASSET_PRICE  ctrlSetText format["Price: %1", [PURCHASE_MENU_CART_ITEM select 2, true] call fnc_standardNumericalNotationString];
			ASSET_PREVIEW ctrlSetText (getText (configfile >> "CfgVehicles" >> (PURCHASE_MENU_CART_ITEM select 1) >> "editorPreview"));
			true
		}]; 
		
		_ctrlEdit ctrlCommit 0; 

		_control_id_index     = _control_id_index + 1;
		_control_height_index = _control_height_index + 0.05;			

	} forEach _groupArray;

	_group_index = _group_index + 1;

} forEach ISRC_BUILDABLE_OBJECTS;

private _cancel = _display ctrlCreate ["RscShortcutButton", -1, _ctrlBackground]; 
_cancel ctrlSetPosition [0.25, 0.75, 0.25, 0.05]; 
_cancel ctrlCommit 0; 
_cancel ctrlSetText " CANCEL "; 
_cancel ctrlAddEventHandler ["ButtonClick", {
	params ["_ctrl"]; 
	_display = ctrlParent _ctrl; 
	_display closeDisplay 1;
	PURCHASE_MENU_OPEN = false; 
}]; 

private _ctrlButton = _display ctrlCreate ["RscShortcutButton", -1, _ctrlBackground]; 
_ctrlButton ctrlSetPosition [0.5, 0.75, 0.25, 0.05]; 
_ctrlButton ctrlCommit 0; 
_ctrlButton ctrlSetText "   BUY"; 
_ctrlButton ctrlAddEventHandler ["ButtonClick",  
{ 

	params ["_ctrl"]; 
	if (count PURCHASE_MENU_CART_ITEM == 0) exitWith {
		hint "No items in cart!";
	};

	_display = ctrlParent _ctrl; 
	_display closeDisplay 1;

	CURRENT_FUNDING_BALANCE_BM = [missionNamespace, "CURRENT_FUNDING_BALANCE", 0] call BIS_fnc_getServerVariable;

	if (CURRENT_FUNDING_BALANCE_BM < PURCHASE_MENU_CART_ITEM select 2) exitWith {
		systemChat format ["Error: You do not have enough funding to build %1!", _objDetails select 0];
	};

	[PURCHASE_MENU_CART_ITEM select 2] remoteExec ["fnc_subtractFunding", 2];
	private _obj = (PURCHASE_MENU_CART_ITEM select 1) createVehicle ([player, 15] call fnc_inFrontOf);

	[_obj] spawn {
		
		private _obj = _this select 0;

		sleep 1;

		[_obj, ["is_prop", true]] remoteExec ["setVariable", 0, _obj]; // global - jip
		_obj setVariable ["is_prop", true]; // local
		[_obj, ["isrc_engineer_movable", true]] remoteExec ["setVariable", 0, _obj]; // global - jip
		_obj setVariable ["isrc_engineer_movable", true]; // local
		[_obj, false] remoteExec ["allowDamage", 0, _obj]; // global - jip
		_obj allowDamage false; // local
		_obj enableSimulationGlobal false; // global

		[_obj] remoteExec ["fnc_addPersistentObject", 2]; // to server
	};

	PURCHASE_MENU_CART_ITEM    = [];	
	PURCHASE_MENU_OPEN         = false;
	CURRENT_FUNDING_BALANCE_BM = 0;
	true 
}]; 
_ctrlGroup ctrlSetPosition [0.25, 0.25, 0.5, 0.5]; 
_ctrlGroup ctrlCommit 0.1; 
//playSound "Hint3";
