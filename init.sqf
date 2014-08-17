/**
 * mf-tow/init.sqf
 * The main script for initalising towing functionality. 
 *
 * Created by Matt Fairbrass (matt_d_rat)
 * Version: 1.1.2
 * MIT Licence
 **/

private ["_cursorTarget", "_towableVehicles", "_towableVehiclesTotal"];

// Public variables
MF_Tow_Base_Path		= "addons\mf-tow"; 		// The base path to the MF-Tow Folder.
MF_Tow_Distance			= 10;					// Minimum distance (in meters) away from vehicle the tow truck must be to tow.
MF_Tow_Multi_Towing	 	= false;				// Allow a vehicle which is towing another vehicle already to be towed by another tow. Disabled by default.

MF_Tow_TowAllowSpecial = ["TowingTractor","tractor","tractorold"]; // Towing Tractor
MF_Tow_TowAllowSuperHeavy = ["BTR90_HQ_DZE","LAV25_HQ_DZE","Ural_CDF","Ural_TK_CIV_EP1","Ural_UN_EP1","V3S_Open_TK_CIV_EP1","V3S_Open_TK_EP1","V3S_Refuel_TK_GUE_EP1_DZ","UralRefuel_TK_EP1_DZ","Kamaz","KamazRefuel_DZ","MtvrRefuel_DES_EP1_DZ","MTVR_DES_EP1"]; // Trucks
MF_Tow_TowAllowHeavy = ["HMMWV_M1035_DES_EP1","HMMWV_DES_EP1","HMMWV_DZ","HMMWV_M998A2_SOV_DES_EP1_DZE","HMMWV_M1151_M2_CZ_DES_EP1_DZE","HMMWV_M1151_M2_CZ_DES_EP1","GAZ_Vodnik_DZE","GAZ_Vodnik_MedEvac","HMMWV_Ambulance","HMMWV_Ambulance_CZ_DES_EP1"]; // Military/4x4
MF_Tow_TowAllowMedium = ["BAF_Offroad_W","SUV_Blue","SUV_Camo","SUV_Charcoal","SUV_Green","SUV_Orange","SUV_Pink","SUV_Red","SUV_Silver","SUV_TK_CIV_EP1","SUV_White","SUV_Yellow","UAZ_CDF","UAZ_INS","UAZ_MG_TK_EP1_DZE","UAZ_RU","UAZ_Unarmed_TK_EP1","UAZ_Unarmed_UN_EP1","S1203_ambulance_EP1","S1203_TK_CIV_EP1","Pickup_PK_GUE_DZE","Pickup_PK_INS_DZE","Pickup_PK_TK_GUE_EP1_DZE","Offroad_DSHKM_Gue_DZE","LAndRover_CZ_EP1","LandRover_MG_TK_EP1_DZE","LandRover_Special_CZ_EP1_DZE","LandRover_TK_CIV_EP1","Ikarus","Ikarus_TK_CIV_EP1","ArmoredSUV_PMC","ArmoredSUV_PMC_DZ","ArmoredSUV_PMC_DZE","UAZ_Unarmed_TK_CIV_EP1","hilux1_civil_1_open","hilux1_civil_2_covered","hilux1_civil_3_open","hilux1_civil_3_open_EP1","datsun1_civil_1_open","datsun1_civil_2_covered","datsun1_civil_3_open"]; // Heavy Cars
MF_Tow_TowAllowLight = ["policecar","VolhaLimo_TK_CIV_EP1","Volha_1_TK_CIV_EP1","Volha_2_TK_CIV_EP1","VWGolf","Skoda","SkodaBlue","SkodaGreen","SkodaRed","car_hatchback","car_sedan","Lada1","Lada1_TK_CIV_EP1","Lada2","Lada2_TK_CIV_EP1","LadaLM"]; // Cars
MF_Tow_TowAllowFeather = ["TT650_Civ","TT650_Ins","TT650_TK_CIV_EP1","ATV_CZ_EP1","ATV_US_EP1","GLT_M300_LT","GLT_M300_ST","M1030_US_DES_EP1","Old_moto_TK_Civ_EP1"]; // ATV's

// Functions

/**
 * Returns an array of towable objects which can be pulled by the tow truck.
 * Configure this as required to set which vehicles can pull which types of other vehicles.
 **/
MF_Tow_Towable_Array =
{
    private ["_vehicleClass","_array","_towTruck","_towClass"];
    _towTruck = _this select 0; // cursor target
	_vehicleClass = typeOf _towTruck;
	_towClass = "";
	
	if (_vehicleClass in MF_Tow_TowAllowFeather) then { _towClass = "Feather"; };
	if (_vehicleClass in MF_Tow_TowAllowLight) then { _towClass = "Light"; };
	if (_vehicleClass in MF_Tow_TowAllowMedium) then { _towClass = "Medium"; };
	if (_vehicleClass in MF_Tow_TowAllowHeavy) then { _towClass = "Heavy"; };
	if (_vehicleClass in MF_Tow_TowAllowSuperHeavy) then { _towClass = "SuperHeavy"; };
	if (_vehicleClass in MF_Tow_TowAllowSpecial) then { _towClass = "TowingTractor"; };

	_array = [];
	
	switch (_towClass) do
	{
		case "Feather": 						{_array = ["Motorcycle"];};
		case "Light":							{_array = ["Motorcycle","Car"];};
		case "Medium": 							{_array = ["Motorcycle","Car","Bus"];};
		case "Heavy": 							{_array = ["Motorcycle","Car","Bus","Truck"];};
		case "SuperHeavy": 						{_array = ["LandVehicle"];};
		case "TowingTractor": 					{_array = ["LandVehicle","Air"];};
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