MF-Tow
======
*MF-Tow (a towing script for DayZ Epoch mod)*

## Introduction ##

MF-Tow enables vehicles to be towed by others. It has been designed to be highly configureable, allowing server admins to define which vehicles can tow, and what types of vehicles they can tow. 

This script builds upon the ideas laid down by the built-in tow system in DayZ Epoch, but with more features and a better configurable ease of use. 

MF-Tow was inspired by the great work done by the R3F team on their '[R3F] Artillery and Logistic' addon, and serves as an alternative tow script for admins who just want to add towing functionality to their DayZ Epoch server. 

MF-Tow is also fully compatible with the popular '=BTC=_Logistic (DayZ Epoch Version)'.

## Features ##
- Define exactly what vehicles can tow.
- Define what types of vehicles can be towed (ie: "Motorcycle", "Car", "Truck", "Wheeled_APC", "Tracked_APC", "Air" etc..)
- Disable towing of locked vehicles (optional)
- Requires a player to have a toolbox in their inventory in order to be able to attach a tow.

## Configuration ##

### Configuring tow vehicles & towable vehicles ###

[Download](https://github.com/matt-d-rat/mf-tow/archive/master.zip) and extract the zip file to a folder called ```mf-tow```, inside you will find a file called ```init.sqf```, open this file up in a text editor.

Locate the ```MF_Tow_Towable_Array``` function, this function defines which vehicles can tow (declared as cases for each vehicle [class name](https://docs.google.com/spreadsheet/ccc?key=0AjNSjNkQ9qIVdHpCU0pXZVdfZmNZZFlpNHEwQUp2bVE&usp=sharing#gid=0) in the switch statement), and the types of vehicles that each case is able to tow (defined as an array of vehicle types).

```sqf
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
		case "HMMWV_M1151_M2_CZ_DES_EP1_DZE": 	{_array = ["Motorcycle","Car","Truck"];};
		case "HMMWV_M1151_M2_CZ_DES_EP1": 		{_array = ["Motorcycle","Car","Truck"];};
		case "tractor": 						{_array = ["Motorcycle","Car","Truck"];};
		case "TowingTractor":                   {_array = ["Motorcycle","Car","Truck","Wheeled_APC","Tracked_APC","Air"];};
	};
	
	_array
};
```
So for example, we can see that the code above permits the ```ArmoredSUV_PMC``` to tow vehicles which are of either a type of ```Motorcycle``` or ```Car```. Nothing else.

To add a new vehicle which can be used as a towing vehicle, add a new case to the switch statement and define an array of the types of vehicles which can be towed (be careful not to have a trailing comma after the last entry in the array!):

```sqf
case "Pickup_PK_INS_DZE": {_array = ["Motorcycle","Car"];};
```

### Enabling Multi-tow ###

By default, towing vehicles which are currently towing another vehicle is disabled (patched in v1.1.1). To enable this functionality, set the ```MF_Tow_Multi_Towing``` variable in ```init.sqf``` to true.

```sqf
MF_Tow_Multi_Towing = true; // Warning, this is not recommended!
```

Although this may seem like a nice feature, in reality the only purpose it will probably serve is to allow people to troll one another. The choice is entirely yours though :-).

## Installation Guide ##

- __Download__: https://github.com/matt-d-rat/mf-tow/archive/master.zip
- __Difficulty__: Intermediate
- __Install time__: 10-15 minutes
- __Requirements__:
    - Text editor
    - PBO extrator
    - Coffee or beer

__Step 1:__ [Download](https://github.com/matt-d-rat/mf-tow/archive/master.zip) and extract the zip file to a folder called ```mf-tow```.

__Step 2:__ In your ```MPMissions``` folder (eg, DayZ_Epoch_11.Chernarus), create a folder called ```addons``` if one doesn't exist already.

__Step 3:__ Copy the ```mf-tow``` folder into the ```addons``` folder.

__Step 4:__ Add ```[] execVM "addons\mf-tow\init.sqf";``` at the end of your ```init.sqf```


### Known Issues ###
1. Vehicles which have been towed and detached must be entered at least once in order for the server to update the vehicles world postion, ensuring the vehicle remain at that position on server restart.

### Change Log ###

#### v1.1.2 ###
- Fixed bug which allowed players to enter towed vehicles, allowing them to ghost through walls to gain access to modular bases.
- Added a check to interupt the attaching of the tow if a player enters the vehicle during the attachment phase.

#### v1.1.1 ###
- Fixed exploit which allowed players to tow vehicles which were already being towed.
- Fixed exploit which allowed players to tow vehicles which were already towing another vehicle. This functionality can be turned back on via the ```MF_Tow_Multi_Towing``` config param being set to true (default value is false). Be warned, turning this on produces "interesting" results and probably only serves as a means for trolling.

#### v1.1.0 ###
- Non-breaking changes to the check for whether the cursor target is a towable vehicle.
- Deprecated MF_Tow_Towable variable as it is no longer used as a check condition.
- Vehicles which can tow and be towed are now maintained in MF_Tow_Towable_Array function, removing the need to
maintain two seperate arrays.
- Updated the install guide to reflect the changes above.
- Fixed the z-axis offset issues with the UAZ as the tow vehicle and as the towable vehicle which caused the UAZ to either be in the air or under ground during towing.
- Fixed player z-axis offset to the UAZ when in animation state. This was again due to the bounding box data on the UAZ being completely incorrect.

#### v1.0.1 ###
- Corrected a minor typo in the install guide.

#### v1.0.0 ###
- Initial release.
- Added the requirement for the player to have a toolbox in their inventory.
- Added feature to prevent the towing of locked vehicles.
- Configurable array of tow vehicles and which types of vehicles they can tow.
- Added install guide.
