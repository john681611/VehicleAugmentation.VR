/*V3.0
To Run: execVM "VehicleAugmentation.sqf"; in your init.sqf file
-----------------------CONFIG--------------------------------------------------
Vehicles allowed to be Augmented
*/
AUG_Vehicles = [
//Default
"B_G_Offroad_01_F",
"I_G_Offroad_01_F",
"O_G_Offroad_01_F",
"C_Offroad_01_F",

"I_G_Van_01_transport_F",
"B_G_Van_01_transport_F",
"O_G_Van_01_transport_F",
"I_C_Van_01_transport_F",
"C_Van_01_transport_F",

"I_C_Offroad_02_unarmed_F",
"C_Offroad_02_unarmed_F",

"I_C_Boat_Transport_02_F",
"C_Boat_Transport_02_F",

"B_Boat_Transport_01_F",
"B_T_Boat_Transport_01_F",
"B_G_Boat_Transport_01_F",
"O_Boat_Transport_01_F",
"O_T_Boat_Transport_01_F",
"O_G_Boat_Transport_01_F",
"I_Boat_Transport_01_F",
"I_C_Boat_Transport_01_F",

"B_Lifeboat",
"B_T_Lifeboat",
"O_Lifeboat",
"O_T_Lifeboat",

"C_Rubberboat"

];
/*Positioning/Script config:
Pos : Attaching position
dir: Orentation vs front of vehicle unitName
(optional Code): For running animations or hiding items:
  								(_this select 0) = Vehicle
*/
AUG_VehConfig = [
//Default [vehicles,[MG pos,dir,(optional Code)],[LMG pos,dir,(optional Code)],[L pos,dir,(optional Code)],[M pos,dir,(optional Code)]]
[["B_G_Offroad_01_F","I_G_Offroad_01_F","O_G_Offroad_01_F","C_Offroad_01_F"],[[0.25,-2,1],0],[[-0.1,-2,0.5],180,{(_this select 0) animate ["HideDoor3", 1];}],[[0,-1.5,0.25],180],[[0,-2,0],0]],
[["I_G_Van_01_transport_F","B_G_Van_01_transport_F","O_G_Van_01_transport_F","I_C_Van_01_transport_F","C_Van_01_transport_F"],[[0.25,-2,1],0],[[-0.1,-2,0.6],180],[[0,-1.5,0.4],180],[[0,-2,0.1],0]],
[["I_C_Offroad_02_unarmed_F","C_Offroad_02_unarmed_F"],[[0.25,-1,1],0,{(_this select 0) animate ["hideRearDoor",1]; (_this select 0) animate["hideSeatsRear",1];}],[[-0.1,-1,0.5],180,{(_this select 0) animate ["hideRearDoor",1]; (_this select 0) animate["hideSeatsRear",1];}],[[0,-0.8,0.25],180,{(_this select 0) animate ["hideRearDoor",1]; (_this select 0) animate["hideSeatsRear",1];}],[[0,-1.5,0],0,{(_this select 0) animate ["hideRearDoor",1]; (_this select 0) animate["hideSeatsRear",1];}]],

[["I_C_Boat_Transport_02_F","C_Boat_Transport_02_F"],[[0.25,2,1],0],[[-0.1,2,1],0],[[0,1.5,0.4],0],[[0,2,0.1],0]],
[["B_Boat_Transport_01_F","B_T_Boat_Transport_01_F","B_G_Boat_Transport_01_F","O_Boat_Transport_01_F","O_T_Boat_Transport_01_F","O_G_Boat_Transport_01_F","I_Boat_Transport_01_F","I_C_Boat_Transport_01_F","B_Lifeboat","B_T_Lifeboat","O_Lifeboat","O_T_Lifeboat","C_Rubberboat"],[[0.25,1,0.7],0],[[0,1.7,0.6],0],[[0,1,0],0],[[0,1,-0.25],0]]
];
//Global List of weapons that can be mounted
//Machine Guns
AUG_MG = ["I_HMG_01_high_F","I_GMG_01_high_F","O_HMG_01_high_F","O_GMG_01_high_F","B_HMG_01_high_F","B_GMG_01_high_F"];
//Low Machine Guns
AUG_LMG = ["I_HMG_01_F","I_GMG_01_F","O_HMG_01_F","O_GMG_01_F","B_HMG_01_F","B_GMG_01_F","I_HMG_01_A_F","I_GMG_01_A_F","O_HMG_01_A_F","O_GMG_01_A_F","B_HMG_01_A_F","B_GMG_01_A_F"];
//Launchers
AUG_L = ["I_static_AA_F","I_static_AT_F","O_static_AA_F","O_static_AT_F","B_static_AA_F","B_static_AT_F"];
//Mortars
AUG_M = ["I_Mortar_01_F","O_Mortar_01_F","B_Mortar_01_F","B_G_Mortar_01_F"];

//-------------------------------END CONFIG-------------------------------------
AUG_ALL = [] + AUG_MG + AUG_LMG + AUG_L+ AUG_M;

//setup MP
mpAddEventHand = {
private["_obj","_type","_code"];
_obj = _this select 0;
_type = _this select 1;
_code = _this select 2;
_add = _obj addEventHandler [_type,_code];
};
mpRemoveEventHand = {
private["_obj","_type","_index"];
_obj = _this select 0;
_type = _this select 1;
_index = _this select 2;
_obj removeEventHandler [_type, _index];
};


mpSetDir = {
private["_obj","_dir"];
_obj = _this select 0;
_dir = _this select 1;

_obj setDir _dir;
};

//Functions
AUG_Init = {
	{
	 if(typeof _x in  AUG_Vehicles && isNil {_x getVariable "AUG_Act"}) then {
		 [_x] spawn AUG_AddAction;
		 [_x] spawn AUG_Scan;
		 };
	} foreach vehicles; //Units
};

AUG_AddAction = {
	// mp issues may occure
	_ls = [ (_this select 0),"","","","speed _target <= 1 AND speed _target >= -1 AND _target distance _this < 5  AND vehicle _this == _this AND ( typeNAME (_target getVariable 'AUG_Attached') != 'BOOL' OR typeNAME (_target getVariable 'AUG_Local') != 'BOOL')","true",{},{},{},{},[],13,nil,false,false] call BIS_fnc_holdActionAdd;
	_vls = (_this select 0) addAction ["", {[(_this select 0),(_this select 1)] spawn AUG_GetIn;},[],5.5,true,true,"","typeNAME (_target getVariable 'AUG_Attached') != 'BOOL' AND _target distance _this < 5"];
	(_this select 0) setVariable ["AUG_Act",_ls,false];
	(_this select 0) setVariable ["AUG_Act_GetIn",_vls,false];
	(_this select 0) setVariable["AUG_Attached",false,true];
	(_this select 0) setVariable["AUG_Local",false,true];


};

AUG_UpdateState = {
	//Update Action
	[(_this select 0),((_this select 0) getVariable "AUG_Act")] call BIS_fnc_holdActionRemove;
 	_ls = [ (_this select 0),(_this select 1),
				"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
				"\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa",
				"speed _target <= 1 AND speed _target >= -1 AND _target distance _this < 5 AND vehicle _this == _this AND ( typeNAME (_target getVariable 'AUG_Attached') != 'BOOL' OR typeNAME (_target getVariable 'AUG_Local') != 'BOOL')",
				"true",
					{(_this select 1) playMoveNow  "Acts_carFixingWheel";}
					,{},
					{(_this select 1) switchmove "";[(_this select 0)] Call AUG_Action;},
					{(_this select 1) switchmove "";},[],13,1.5,false,false] Call BIS_fnc_holdActionAdd;
	(_this select 0) setVariable ["AUG_Act",_ls,false];

};
AUG_UpdateGetInState = {
	//Update Action
	(_this select 0) setUserActionText [(_this select 0) getVariable "AUG_Act_GetIn",(_this select 1),(_this select 2)];
};


AUG_Action = {
	_veh = (_this select 0);
	if( typeNAME(_veh getVariable["AUG_Attached",false]) == "OBJECT")  then {
		[_veh,(_this select 1)] call AUG_Detach;
	}else{
		[_veh,(_this select 1)] call AUG_Attach;

	}
};
AUG_GetIn = {
	_aug = (_this select 0) getVariable["AUG_Attached",false];
	if((count (crew _aug)) > 0) exitWith {hint 'Weapon must be empty to mount';};
	(_this select 1) moveInGunner _aug;
};

AUG_Scan = {
	_veh = (_this select 0);
	while {alive _veh } do {
	if (speed _veh <= 1 AND speed _veh >= -1 && typeNAME (_veh getVariable["AUG_Attached",false]) != "OBJECT" ) then {
			//Detection
			_NO = nearestObjects [[(_veh modelToWorld [0,-5,0]) select 0,(_veh modelToWorld [0,-5,0]) select 1,0],AUG_ALL,5];
			if((count _NO)>=1)then {
				_aug = (_NO select 0);
				_current =  _veh getVariable["AUG_Local",false];
				_test  =  false;
				//Duplicate Test
				if(typeNAME _current != "BOOL") then {
					if(_current != _aug) then {
						_test  =  true;
					};
				}else{
					_test  =  true;
				};
				if(_test) then {
					//Display name
					_Cname = typeOf _aug;
					_Dname = getText (configFile >> "cfgVehicles" >> _Cname >> "displayName");
					[[_veh,format["<t color='#00ff00'>Attach %1</t>",_Dname]],"AUG_UpdateState",true,true] spawn BIS_fnc_MP;
					//SetVariable
					_veh setVariable["AUG_Local",_aug,true];
				};
			}else{
				//Hide if nothing
				_veh setVariable["AUG_Local",false,true];
				[[_veh,""],"AUG_UpdateState",true,true] spawn BIS_fnc_MP;
			};
		};
		sleep 1;
	};
};

AUG_Attach = {
private["_veh","_aug"];	//Import Variables
	_veh = (_this select 0);
	_aug = _veh getVariable["AUG_Local",false];
	if((count (crew _aug)) > 0) exitWith {hint 'Weapon must be empty to mount';};
	{
		if((typeOf _veh) in (_x select 0)) then{
			_vars = ["",""];
			if(typeOf _aug in AUG_MG) then {_vars = (_x select 1);};
			if(typeOf _aug in AUG_LMG) then {_vars = (_x select 2);};
			if(typeOf _aug in AUG_L) then {_vars = (_x select 3);};
			if(typeOf _aug in AUG_M) then {_vars = (_x select 4);};

			_aug attachto [_veh,(_vars select 0)];
			[[_aug,(_vars select 1)],"mpSetDir",true,true] spawn BIS_fnc_MP;
			[_veh] spawn (_vars select 2);
		};
	} foreach AUG_VehConfig;
	//Event Handler ((getpos (_this select 0))findEmptyPosition [2,10,"Man"])
	[[_aug,"GetOut",{(_this select 2) moveInany (attachedTo(_this select 0)); 	doGetOut (_this select 2); }],"mpAddEventHand",true,true] spawn BIS_fnc_MP;

	 _veh setVariable["AUG_Attached",_aug,true];
	 _veh setVariable["AUG_Local",false,true];

	 //Display name
	 _Cname = typeOf _aug;
	 _Dname = getText (configFile >> "cfgVehicles" >> _Cname >> "displayName");
	 [[_veh,format["Get in %1 as Gunner",_Dname],"<img size='2' image='\a3\ui_f\data\IGUI\Cfg\Actions\getingunner_ca.paa'/>"],"AUG_UpdateGetInState",true,true] spawn BIS_fnc_MP;
	 [[_veh,format["<t color='#ff0000'>Detach %1</t>",_Dname]],"AUG_UpdateState",true,true] spawn BIS_fnc_MP;
};

AUG_Detach = {
	private["_veh"];	//Import Variables
	_veh = (_this select 0);
	_aug = _veh getVariable "AUG_Attached";
	if((count (crew _aug)) > 0) exitWith {hint 'Weapon must be empty to dismount';};
	//Detach
	detach _aug;
	_aug setPos [(_veh modelToWorld [0,-5,0]) select 0,(_veh modelToWorld [0,-5,0]) select 1,0];
	//Remove event Handler
	[[_aug,"GetOut", 0],"mpRemoveEventHand",true,true]spawn BIS_fnc_MP;
	_veh setVariable["AUG_Attached",false,true];
};
diag_log "Augmentation Script Loaded";
//temp
While {true} do {
	[[],"AUG_Init",true,true] spawn BIS_fnc_MP;
sleep 15;
};
