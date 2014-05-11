/**
 * mf-tow/init.sqf
 * The main script for initalising towing functionality. 
 *
 * Created by Matt Fairbrass (matt_d_rat)
 * Version: 1.1.1
 * MIT Licence
 **/

private ["_cursorTarget", "_towableVehicles", "_towableVehiclesTotal"];

// Public variables
MF_Tow_Base_Path		= "addons\mf-tow"; 		// The base path to the MF-Tow Folder.
MF_Tow_Distance			= 10;					// Minimum distance (in meters) away from vehicle the tow truck must be to tow.
MF_Tow_Multi_Towing	 	= false;				// Allow a vehicle which is towing another vehicle already to be towed by another tow. Disabled by default.

// Functions

/**
 * Returns an array of towable objects which can be pulled by the tow truck.
 * Configure this as required to set which vehicles can pull which types of other vehicles.
 **/
MF_Tow_Towable_Array =
{
    private ["_array","_towTruck"];
    _towTruck = _this select 0;
	_array = [];
	
	switch (typeOf _towTruck) do
	{
		case "ATV_CZ_EP1": 						{_array = ["Motorcycle"];};
		case "ATV_US_EP1": 						{_array = ["Motorcycle"];};
		case "hilux1_civil_3_open": 			{_array = ["Motorcycle","Car"];};
		case "hilux1_civil_3_open_EP1": 		{_array = ["Motorcycle","Car"];};
		case "ArmoredSUV_PMC":					{_array = ["Motorcycle","Car"];};
		case "ArmoredSUV_PMC_DZ": 				{_array = ["Motorcycle","Car"];};
		case "ArmoredSUV_PMC_DZE": 				{_array = ["Motorcycle","Car"];};
		case "UAZ_Unarmed_TK_CIV_EP1":			{_array = ["Motorcycle","Car"];};
		case "HMMWV_M1151_M2_CZ_DES_EP1_DZE": 	{_array = ["Motorcycle","Car","Truck"];};
		case "HMMWV_M1151_M2_CZ_DES_EP1": 		{_array = ["Motorcycle","Car","Truck"];};
		case "tractor": 						{_array = ["Motorcycle","Car","Truck"];};
		case "TowingTractor": 					{_array = ["Motorcycle","Car","Truck","Wheeled_APC","Tracked_APC","Air"];};
	};
	
	_array
};

/**
 * Animate the player in a towing action, whilst attaching them to the tow vehicle to ensure safety.
 **/
MF_Tow_Animate_Player_Tow_Action =
{
	private ["_towTruck","_offsetZ"];
	_towTruck = _this select 0;
	_offsetZ = 0.1;
	
	// Bounding box on UAZ is screwed, offset z-axis correctly
	if(_towTruck isKindOf "UAZ_Base") then {
		_offsetZ = 1.8;
	};
	
	[player,20,true,(getPosATL player)] spawn player_alertZombies; // Alert nearby zombies
	[1,1] call dayz_HungerThirst; // Use some hunger and thirst to perform the action
	
	// Attach the player to the tow truck temporarily for safety so that they aren't accidentally hit by the vehicle when it gets attached
	player attachTo [_towTruck, 
		[
			(boundingBox _towTruck select 1 select 0),
			(boundingBox _towTruck select 0 select 1) + 1,
			(boundingBox _towTruck select 0 select 2) - (boundingBox player select 0 select 2) + _offsetZ
		]
	];

	player setDir 270;
	player setPos (getPos player);
	player playActionNow "Medic"; // Force the animation
};

MF_Tow_Get_Vehicle_Name =
{
	private ["_vehicle", "_configVeh", "_vehicleName"];
	_vehicle = _this select 0;
	
	_configVeh = configFile >> "cfgVehicles" >> TypeOf(_vehicle);
	_vehicleName = getText(_configVeh >> "displayName");
	
	_vehicleName
};

// Initialise script
_cursorTarget = cursorTarget;
_towableVehicles = [_cursorTarget] call MF_Tow_Towable_Array;
_towableVehiclesTotal = count (_towableVehicles);

// Add the action to the players scroll wheel menu if the cursor target is a vehicle which can tow.
if(_towableVehiclesTotal > 0) then {
	if (s_player_towing < 0) then {
		if(!(_cursorTarget getVariable ["MFTowIsTowing", false])) then {
			s_player_towing = player addAction ["Attach Tow", format["%1\tow_AttachTow.sqf", MF_Tow_Base_Path], _cursorTarget, 0, false, true, "",""];				
		} else {
			s_player_towing = player addAction ["Detach Tow", format["%1\tow_DetachTow.sqf", MF_Tow_Base_Path], _cursorTarget, 0, false, true, "",""];			
		};
	};
} 
else {
	player removeAction s_player_towing;
	s_player_towing = -1;
};