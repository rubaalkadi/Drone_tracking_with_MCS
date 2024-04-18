pragma experimental ABIEncoderV2;
        
        
contract authority{
    // events 
    event DroneRegistered(uint _droneId);

    //structs
struct Drone{
    uint32 droneSerial; 
    uint32 ownerId;
    uint32 rewards;
    uint32 panalties;
    bool hasActivePlan;
    address payable ownerAdd;
    
}
struct Plan {
    uint coordinates;
    uint time;
    uint date;
    uint altitude; 
    uint missionRID;
}

// arrays and mappings
    Drone[] public registeredDrones; 
    Plan [] public missionPlan;
    
    mapping(address=>bool) public RegisteredUSS;
    mapping (uint32 => bool) RegisteredSerial;
    address USS_SCowner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;// for testing
   
    
    modifier _registeredSerial(uint32 _droneSerial){
        require(RegisteredSerial[_droneSerial] == false, 'Drone already registered');
        _;
    }
   
   
    modifier OnlyUSSSCowner{
      require(msg.sender == USS_SCowner);
      _;
    }
    // register USS
   
    function RegisterUSS(address a) OnlyUSSSCowner public{
        RegisteredUSS[a]=true;
    }
    
   
    function RevokeUSS(address a) OnlyUSSSCowner public{
        RegisteredUSS[a]=false;
    }
    
    // register drone 
    
    function registerDrone (uint32 _droneSerial, uint32 _ownerId, bool _signTAC) public _registeredSerial(_droneSerial) {
        require(_signTAC, 'Please accept the terms and conditions');
         require(_droneSerial <2^32);
        require(_ownerId <2^32); 
     //   require(registeredDrones.length < 10^10);
       // uint id = registeredDrones.push(Drone(_droneSerial, _ownerId, 0,0,false,msg.sender));
        RegisteredSerial[_droneSerial]=true;
       // emit DroneRegistered(id);
       // return id; 
    }
   

    
}
