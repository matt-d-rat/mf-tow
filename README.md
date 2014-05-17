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

Next, we need to add the call to the MF-Tow's ```init.sqf``` script to the ```fn_selfActions.sqf``` which involves overriding the default DayZ Epoch ```compiles.sqf``` and ```fn_selfActions.sqf``` files. If you haven't created a custom ```compiles.sqf``` before proceed to __step 4__, otherwise skip ahead to __step 8__.

__Step 4:__ Locate your ```@dayz_epoch``` folder, this is normally found in your Arma2 Operation Arrowhead folder (depending on how you installed the game). 

Steam users For example will find it installed here: 
```
C:\Program Files (x86)\Steam\SteamApps\common\Arma 2 Operation Arrowhead\
```

Locate the ```dayz_code.pbo``` file inside your ```@dayz_epoch\addons\``` folder and copy it to your desktop.

__Step 5:__ Extract the contents of the ```dayz_code.pbo``` file you copied to your desktop using a PBO tool. I recommend [PBOManager](http://www.armaholic.com/page.php?id=16369). Open the folder you extracted the contents to and grab a copy of ```compiles.sqf``` located in ```dayz_code\init\```.

__Step 6:__ Paste the ```compiles.sqf``` to the root of your ```MPMissions``` folder (eg, DayZ_Epoch_11.Chernarus).


__Step 7:__ Now we need to update our MPMission to load our custom ```compiles.sqf```, so open up ```init.sqf``` located in the root of your MPMission folder in a text editing program. I recommend [Notepad++](http://notepad-plus-plus.org/).

Around __line 54__ look for the following:

```sqf
call compile preprocessFileLineNumbers "\z\addons\dayz_code\init\compiles.sqf";
```

and change it to this:

```sqf
call compile preprocessFileLineNumbers "compiles.sqf";
```

Our server will now load our custom ```compiles.sqf``` file instead.

__Step 8:__ In your ```MPMissions``` folder (eg, DayZ_Epoch_11.Chernarus), create a folder called ```compile```. This is where we will put our custom compile files to keep them nice and organised (this also massively helps when it comes to upgrading versions of DayZ Epoch Server).

__Step 9:__ Grab a copy of ```fn_selfActions.sqf``` from ```@dayz_code\compile``` and paste it into the ```compile``` folder you created in Step 8.

__Step 10:__ Open your custom ```compiles.sqf``` located at the root of your ```MPMissions``` folder in a text editor. Around __line 14__ look for this:

```sqf
fnc_usec_selfActions = compile preprocessFileLineNumbers "\z\addons\dayz_code\compile\fn_selfActions.sqf";
```
and change it to this:

```sqf
fnc_usec_selfActions = compile preprocessFileLineNumbers "compile\fn_selfActions.sqf";
```
Our server will now load our custom ```fn_selfActions.sqf``` file instead.

__Step 11:__ Finally, open your custom ```fn_selfActions.sqf`` in a text editor. Around line __711-725__ you should see this:

```sqf
	//Towing with tow truck
	/*
	if(_typeOfCursorTarget == "TOW_DZE") then {
		if (s_player_towing < 0) then {
			if(!(_cursorTarget getVariable ["DZEinTow", false])) then {
				s_player_towing = player addAction [localize "STR_EPOCH_ACTIONS_ATTACH" "\z\addons\dayz_code\actions\tow_AttachStraps.sqf",_cursorTarget, 0, false, true, "",""];				
			} else {
				s_player_towing = player addAction [localize "STR_EPOCH_ACTIONS_DETACH", "\z\addons\dayz_code\actions\tow_DetachStraps.sqf",_cursorTarget, 0, false, true, "",""];				
			};
		};
	} else {
		player removeAction s_player_towing;
		s_player_towing = -1;
	};
	*/
```

This is the built in DayZ Epoch towing call, ensure that it is commented out so that it doesn't interfear with MF-Tow. Below this block of code, add the following line to initiate the MF-Tow script.

```sqf
// MF-Tow Script by Matt Fairbrass (matt_d_rat)
call compile preprocessFileLineNumbers 'addons\mf-tow\init.sqf';
```

### Disable towing of locked vehicles (optional) ###

If you want to disable towing of vehicles that are locked to stop those pesky bandits from trolling people follow the optional steps below:

__Step 12:__ Unpack the following files:

- ```dayz_code.pbo``` located in your ```@dayz_epoch``` folder.
- ```dayz_server.pbo```

__Step 13:__ Grab a copy of the ```local_lockUnlock.sqf``` file from ```dayz_code\compile\``` and paste them into your ```compiles``` folder located in the root of your MPMission folder.

__Step 14:__ Open up your copy of ```local_lockUnlock.sqf``` in a text editor. Around __line 5__ locate the following code:

```sqf
if (local _vehicle) then {
	if(_status) then {
		_vehicle setVehicleLock "LOCKED";
	} else {
		_vehicle setVehicleLock "UNLOCKED";
	};
};
```

and change it to:

```sqf
if (local _vehicle) then {
	if(_status) then {
		_vehicle setVehicleLock "LOCKED";
		_vehicle setVariable ["MF_Tow_Cannot_Tow",true,true];
	} else {
		_vehicle setVehicleLock "UNLOCKED";
		_vehicle setVariable ["MF_Tow_Cannot_Tow",false,true];
	};
};
```

__Step 15:__ Open your custom ```compiles.sqf``` file located in the root of your MPMissions folder in a text editor. Around __line 512__ located the following line:

```sqf
local_lockUnlock = compile preprocessFileLineNumbers "\z\addons\dayz_code\compile\local_lockUnlock.sqf";
```

and change it to:

```sqf
local_lockUnlock = compile preprocessFileLineNumbers "compile\local_lockUnlock.sqf";
```

__Step 16:__ Open ```server_publishVehicle2.sqf``` located in the ```dayz_server\compile\``` folder in a text editor. Around __line 4__ locate the following code:

```sqf
if(!_donotusekey) then {
    // Lock vehicle
    _object setvehiclelock "locked";
};
```

and change it to:

```sqf
if(!_donotusekey) then {
    // Lock vehicle
    _object setvehiclelock "locked";
    _object setVariable ["MF_Tow_Cannot_Tow",true,true];
};
```

__Step 17:__ Open ```server_monitor.sqf``` located in the ```dayz_server\system\``` folder in a text editor. Locate the following code:

```sqf
if(_ownerID != "0" and !(_object isKindOf "Bicycle")) then {
	_object setvehiclelock "locked";
};
```

and change it to:

```sqf
if(_ownerID != "0" and !(_object isKindOf "Bicycle")) then {
	_object setvehiclelock "locked";
	_object setVariable ["MF_Tow_Cannot_Tow",true,true];
};
```

__Step 18: Repack ```dayz_server.pbo``` and upload it to your server.

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