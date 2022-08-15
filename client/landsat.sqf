/*_screen = "Land_FlatTV_01_F" createvehicle getposatl player;
_screen setObjectTexture [0, "#(argb,512,512,1)r2t(piprendertg,1)"];

_pipcam = "camera" camCreate [0,0,0];
_pipcam setVectorDirAndUp [[0,0.66,-0.33],[0,0.33,0.66]];
_pipcam cameraEffect ["Internal", "Back", "piprendertg"];
_pipcam camSetFov 0.4;

_campos = getposatl player;

_campos set [2,30];
_pipcam setpos _campos;
*/
// https://forums.bohemia.net/forums/topic/236131-solvedpip-script-and-arsenal/