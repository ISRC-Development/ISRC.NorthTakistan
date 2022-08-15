// Server ->

params ["_playerUnit", "_didJIP"];

if (typeOf _playerUnit == "HeadlessClient_F") exitWith {};

// Add to all zeus curators as editable object.
{_x addCuratorEditableObjects [[_playerUnit], true]} forEach allCurators;



