/**
 * mf-tow/tow_AttachTow.sqf
 * The action for attaching the tow to another vehicle. 
 *
 * Created by Matt Fairbrass (matt_d_rat)
 * Version: 1.1.2
 * MIT Licence
 **/

private ["_towing","_vehicle","_started","_finished","_animState","_isMedic","_abort","_vehicleNameText",
"_towTruckNameText","_findNearestVehicles","_findNearestVehicle","_IsNearVehicle","_towTruck",
"_towableVehicles","_towableVehiclesTotal","_vehicleOffsetY","_towTruckOffsetX","_towTruckOffsetY",
"_offsetZ","_hasToolbox","_searchLoc","_location1","_location2","_facing","_behind"];

if(DZE_ActionInProgress) exitWith { cutText [(localize "str_epoch_player_96") , "PLAIN DOWN"] };
DZE_ActionInProgress = true;

player removeAction s_player_towing;
s_player_towing = 1;

// Tow Truck
_towTruck = _this select 3;
_towableVehicles = [_towTruck] call MF_Tow_Towable_Array;
_towableVehiclesTotal = count (_towableVehicles);
_towTruckNameText = [_towTruck] call MF_Tow_Get_Vehicle_Name;

_towTruckX = getPosATL _towTruck select 0;
_towTruckY = getPosATL _towTruck select 1;
_towTruckDir = getDir _towTruck;

_towOffset = (boundingBox _towTruck select 1 select 1) / 2;
//_findNearestVehicles = nearestObjects [_towTruck, _towableVehicles, MF_Tow_Distance + 15];
_findNearestVehicle = [];

// select the nearest vehicle behind us
for "_i" from _towOffset to MF_Tow_Distance + _towOffset do {
	_towTruckRelX = (sin (_towTruckDir + 180)) * _i;
	_towTruckRelY = (cos (_towTruckDir + 180)) * _i;
	_searchLoc = [_towTruckX + _towTruckRelX, _towTruckY + _towTruckRelY, 0];
//sleep .1;
	/*_nul = [_searchLoc] spawn {
		private ["_loc1","_loc2","_arrow1","_arrow2"];
		_loc1 = _this select 0;
		_arrow1 = createVehicle ["Sign_sphere100cm_EP1", _loc1, [], 0, "CAN_COLLIDE"]; 
		sleep 3;
		deleteVehicle _arrow1;
	};*/

	_findNearestVehicles = nearestObjects [_searchLoc, _towableVehicles, 8];
	{
		if (alive _x && _towTruck != _x) then {
			_findNearestVehicle set [(count _findNearestVehicle),_x];
		};
	} foreach _findNearestVehicles;
	if (count _findNearestVehicle > 0) exitWith { };
};



if(count _findNearestVehicle > 0) then {
	_vehicle = _findNearestVehicle select 0;
	_towableVehicleDir = getDir _vehicle;

	_vehicleNameText = [_vehicle] call MF_Tow_Get_Vehicle_Name;
	_hasToolbox = "ItemToolbox" in (items player);
	
	if (_towTruckDir > 180) then {_towTruckDir = _towTruckDir - 360; };
	if (_towableVehicleDir > 180) then {_towableVehicleDir = _towableVehicleDir - 360; };
	_facing = ((_towableVehicleDir > _towTruckDir - 25) && (_towableVehicleDir < _towTruckDir + 25));
	
	
	_towableVehicleX = getPosATL _vehicle select 0;
	_towableVehicleY = getPosATL _vehicle select 1;

	_towableOffset = (boundingBox _vehicle select 1 select 1) / 2;
	_towOffset = (boundingBox _towTruck select 1 select 1);
	// TowVehicle Bounding Box
	_maxTowDistance = MF_Tow_Distance + (_towableOffset * 2);
	
	for "_i" from _towOffset to MF_Tow_Distance * 6 do {
		_towTruckRelX = (sin (_towTruckDir + 180)) * _i / 8;
		_towTruckRelY = (cos (_towTruckDir + 180)) * _i / 8;
		_towableRelX = (sin (_towableVehicleDir)) * _i / 8;
		_towableRelY = (cos (_towableVehicleDir)) * _i / 8;
		
		_location1 = [_towTruckX + _towTruckRelX, _towTruckY + _towTruckRelY, 0];
		_location2 = [_towableVehicleX + _towableRelX, _towableVehicleY + _towableRelY, 0];
		/*
		sleep .1;
		_nul = [_location1, _location2] spawn {
			private ["_loc1","_loc2","_arrow1","_arrow2"];
			_loc1 = _this select 0;
			_loc2 = _this select 1;
			_arrow1 = createVehicle ["Sign_sphere25cm_EP1", _loc1, [], 0, "CAN_COLLIDE"]; 
			_arrow2 = createVehicle ["Sign_sphere25cm_EP1", _loc2, [], 0, "CAN_COLLIDE"]; 
			sleep 3;
			deleteVehicle _arrow1;
			deleteVehicle _arrow2;
		};*/
		//cutText [ format ["distance: %1", _location1 distance _location2], "PLAIN DOWN"];
		_behind = (_location1 distance _location2 < 2);
		//cutText [ format ["Distance: %1 _towableOffset: %2", (getPos _vehicle) distance _location, _towableOffset], "PLAIN DOWN"];
		if (_behind) exitWith {};
	};

	// Check the player has a toolbox
	if(!_hasToolbox) exitWith {
		cutText ["Cannot attach tow without a toolbox.", "PLAIN DOWN"];
	};

	// Check for vehicle behind tow vehicle
	if(!_behind) exitWith {
		cutText[ format["%1 must be behind %2 to tow.", _vehicleNameText, _towTruckNameText], "PLAIN DOWN"];
	};
	
	if(!_facing) exitWith {
		cutText[ format["%1 must be facing %2 to tow.", _vehicleNameText, _towTruckNameText, _towTruckDir, _towableVehicleDir], "PLAIN DOWN"];
	};
	
	// Check if the vehicle we want to tow is locked
	if((_vehicle getVariable ["MF_Tow_Cannot_Tow", false])) exitWith {
		cutText [format["Cannot tow %1 because it is locked.", _vehicleNameText], "PLAIN DOWN"];
	};
	
	// Check that the vehicle we want to tow is not already being towed by something else.
	if((_vehicle getVariable ["MFTowInTow", false])) exitWith {
		cutText [format["Cannot tow %1 because it is already being towed by another vehicle.", _vehicleNameText], "PLAIN DOWN"];
	};
	
	// Check that the vehicle we want to tow is not already towing something else
	if(!MF_Tow_Multi_Towing && (_vehicle getVariable ["MFTowIsTowing", false])) exitWith {
		cutText [format["Cannot tow %1 because it is already towing another vehicle.", _vehicleNameText], "PLAIN DOWN"];
	};
	
	// Check that the vehicle we want to tow with is not already being towed
	if(!MF_Tow_Multi_Towing && (_towTruck getVariable ["MFTowInTow", false])) exitWith {
		cutText [format["Cannot tow %1 because %2 is already being towed.", _vehicleNameText, _towTruckNameText], "PLAIN DOWN"];
	};
	
	// Check if the vehicle has anyone in it
	if ((count (crew _vehicle)) != 0) exitWith {
		cutText [format["Cannot tow %1 because it has people in it.", _vehicleNameText], "PLAIN DOWN"];
	};
	
	_finished = false;
	
	[_towTruck] call MF_Tow_Animate_Player_Tow_Action;
	
	r_interrupt = false;
	_animState = animationState player;
	r_doLoop = true;
	_started = false;
	
	while {r_doLoop} do {
		_animState = animationState player;
		_isMedic = ["medic",_animState] call fnc_inString;
		if (_isMedic) then {
			_started = true;
		};
		
		if (_started and !_isMedic) then {
			r_doLoop = false;
			_finished = true;
		};
		
		// Check if anyone enters the vehicle while we are attaching the tow and stop the action
		if ((count (crew _vehicle)) != 0) then {
			cutText [format["Towing aborted because the %1 was entered by another player.", _vehicleNameText], "PLAIN DOWN"];
			r_interrupt = true;
		};
		
		if (r_interrupt) then {
			detach player;
			r_doLoop = false;
		};
		
		sleep 0.1;
	};
	r_doLoop = false;

	if(!_finished) then {
		r_interrupt = false;
			
		if (vehicle player == player) then {
			[objNull, player, rSwitchMove,""] call RE;
			player playActionNow "stop";
		};
		_abort = true;
	};

	if (_finished) then {
		if(((vectorUp _vehicle) select 2) > 0.5) then {
			if( _towableVehiclesTotal > 0 ) then {
				_towTruckOffsetX = 0;
				_towTruckOffsetY = 0.8;
				_vehicleOffsetY = 0.8;
				_offsetZ = 0.1;
				
				// Calculate the offset positions depending on the kind of tow truck				
				switch(true) do {
					case (_towTruck isKindOf "ArmoredSUV_Base_PMC");
					case (_towTruck isKindOf "SUV_Base_EP1") : {
						_towTruckOffsetY = 0.9;
					};
					case (_towTruck isKindOf "UAZ_Base" && !(_vehicle isKindOf "UAZ_Base")) : {
						_offsetZ = 1.8;
					};
					case (_towTruck isKindOf "TowingTractor") : {
						_towTruckOffsetX = .3;
					};
					
				};
				
				// Calculate the offset positions depending on the kind of vehicle 
				switch(true) do {
					case (_vehicle isKindOf "Truck" && !(_towTruck isKindOf "Truck")) : {
						_vehicleOffsetY = 0.9;
					};
					case (_vehicle isKindOf "C130J_US_EP1_DZ") : { // done
						_vehicleOffsetY = .8;
						_offsetZ = -.95;
					};
					case (_vehicle isKindOf "AN2_DZ") : { // done
						_vehicleOffsetY = .7;
						_offsetZ = -.45;
					};
					case (_vehicle isKindOf "CH_47F_EP1_DZE") : { // done
						_vehicleOffsetY = .45;
						_offsetZ = -.6;
					};
					case (_vehicle isKindOf "CH53_DZE") : { // done
						_vehicleOffsetY = .35;
						_offsetZ = -9.4;
					};
					case (_vehicle isKindOf "Mi17_Civilian_DZ") : {
						_vehicleOffsetY = .5;
						_offsetZ = -.5;
					};
					case (_vehicle isKindOf "UH60M_EP1_DZE") : { // done
						_vehicleOffsetY = .6;
						_offsetZ = -.3;
					};
					case (_vehicle isKindOf "UH1H_DZE") : { // done
						_vehicleOffsetY = .6;
						_offsetZ = -.2;
					};
					case (_vehicle isKindOf "UH1Y_DZE") : { // done
						_vehicleOffsetY = .05;
						_offsetZ = -.2;
					};
					case (_vehicle isKindOf "MH6J_DZ") : { // done
						_vehicleOffsetY = .6;
						_offsetZ = -.2;
					};
					case (_vehicle isKindOf "MV22_DZ") : { // done
						_vehicleOffsetY = .6;
						_offsetZ = -.85;
					};
					case (_vehicle isKindOf "UAZ_MG_CDF") : { // done
						_offsetZ = -.1;
					};
					case (_vehicle isKindOf "UAZ_Base" && !(_towTruck isKindOf "UAZ_Base") && !(_vehicle isKindOf "UAZ_MG_CDF")) : {
						_offsetZ = -1.8;
					};
				};
					
				// Attach the vehicle to the tow truck
				_vehicle attachTo [ _towTruck,
					[
						_towTruckOffsetX,
						(boundingBox _towTruck select 0 select 1) * _towTruckOffsetY + (boundingBox _vehicle select 0 select 1) * _vehicleOffsetY,
						(boundingBox _towTruck select 0 select 2) - (boundingBox _vehicle select 0 select 2) + _offsetZ
					]
				];
				
				_vehicle lock true; // Disable entering the vehicle while it is in tow.
				VDZE_veh_Lock = [_vehicle,true];
				publicVariable "PVDZE_veh_Lock";
				
				_vehicle setVariable ["MFTowInTow", true, true];
				_towTruck setVariable ["MFTowIsTowing", true, true];
				_towTruck setVariable ["MFTowVehicleInTow", _vehicle, true];
				
				cutText [format["%1 has been attached to %2.", _vehicleNameText, _towTruckNameText], "PLAIN DOWN"];
			};	
		} else {
			cutText [format["Failed to attach %1 to %2.", _vehicleNameText, _towTruckNameText], "PLAIN DOWN"];
		};
	};
} else {
	cutText [format["No vehicles nearby to tow. Move within %1m of a vehicle.", MF_Tow_Distance], "PLAIN DOWN"];
};
DZE_ActionInProgress = false;
s_player_towing = -1;