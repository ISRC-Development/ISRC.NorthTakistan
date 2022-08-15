{
	[_x, 1, ["ACE_SelfActions"], ["isrcEwsRootMenu", "Electronic Warfare", "", {
		nul = execVM "client\experiments\electronic_warfare\ew_menu.sqf";
	}, {true}] call ace_interact_menu_fnc_createAction, true] call ace_interact_menu_fnc_addActionToClass;
} forEach ISRCEWS_ALLOWED_PLATFORMS;


