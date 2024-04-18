pragma experimental ABIEncoderV2;

import "./authority.sol";

contract USS_SC is authority  {
    event DroneSighted(uint _droneId, uint location);
    event missionComplete(uint _missionRID);
    
    mapping (uint => address) public SubscribedDrone;
    mapping (uint => uint32) RIDToNonce;
    mapping (address => uint) requestsPerOwner;
    mapping (bytes => bool) reporters;
    
    // variables 
    uint32 nonce = 0;
    uint zeta = 1; // for testing 
    uint rho = 5 ether; // for testing
    
    uint constant SubscriptionFee = 1 ether;
    uint constant insuranceFee =5 ether;
    
    // modifiers 
    modifier onlyOwnerOfRegistered(uint _droneId){
        require(registeredDrones[_droneId].ownerAdd==msg.sender,'Not the owner of the registered drone');
        _;
    }
    
    modifier onlySubscribed(uint _droneId){
        require(SubscribedDrone[_droneId]== msg.sender,'Not subscribed to USS');
        _;
    }
    modifier NotDroneOwner(uint _droneId){
        require(msg.sender != registeredDrones[_droneId].ownerAdd, 'Owner of drone cannot report it!');
        _;
    }
     // This function is used to subscribe to 
    function USSsubscription (uint _droneId) public onlyOwnerOfRegistered(_droneId) payable {
        require(SubscribedDrone[_droneId]== 0x0000000000000000000000000000000000000000, 'Drone is already subscribed');
        require(msg.value == SubscriptionFee, 'Please make sure to pay a fee of 5 wei');
        SubscribedDrone[_droneId] = msg.sender;
    }
    // to do remove the plan[] and add it to the Drone [] 
    function requestMissionQoute(uint _droneId) onlySubscribed(_droneId) onlyOwnerOfRegistered(_droneId) public view returns(uint){
        return (requestsPerOwner[msg.sender] * zeta + rho + insuranceFee);
    }    
    // this should be payable to avoid blocking the airspace by dummy requests, cost should be calculated based on the number of active missions 
    function requestMissionPlan (uint _droneId, uint _locationA, uint _locationB, uint _departureTime, uint _date) public onlySubscribed(_droneId) payable returns(Plan memory) {
        require(registeredDrones[_droneId].hasActivePlan == false, 'There is already an active plan for this drone');
        requestsPerOwner[msg.sender]++;
        require(msg.value >= ( requestsPerOwner[msg.sender] * zeta + rho + insuranceFee), 'Please make sure to pay the insurance and the mission fee.. mission fee varies depending on the number of requestes per user' ); 
        nonce++;
        uint missionRID = uint((keccak256(abi.encodePacked(nonce + uint(registeredDrones[_droneId].ownerAdd) + _departureTime + _locationA + 12 + _date))));
        missionPlan.push(Plan(_locationA,_departureTime,_date, 12 ,missionRID))-1;
        RIDToNonce[missionRID]=nonce;
        registeredDrones[_droneId].hasActivePlan=true;
        return missionPlan[_droneId];
         
    }
    
   /// need to relook the panalties and rewards
   function droneSightingReport (uint _droneId, uint _missionRID, uint _sightingLocation, uint _sightingTime) NotDroneOwner(_droneId) public returns(bool){
      require(reporters[bytes(abi.encodePacked(uint(msg.sender)+_missionRID))]==false, 'not allowed to report same drone more than once ');
      reporters[abi.encodePacked(uint(msg.sender)+_missionRID)]= true;
      uint RID = uint(keccak256(abi.encodePacked( RIDToNonce[_missionRID] + uint(registeredDrones[_droneId].ownerAdd) + _sightingTime  + _sightingLocation + missionPlan[_droneId].altitude + missionPlan[_droneId].date) ));
                emit DroneSighted(_droneId, missionPlan[_droneId].coordinates);
        msg.sender.transfer(1 ether);
      if (RID == _missionRID){
          registeredDrones[_droneId].rewards++;
          return true; // reward
      }
      else {
            registeredDrones[_droneId].panalties++;
          return false; // panalty 
      }
   }
   
   function missionCompleted (uint _droneId) public onlySubscribed(_droneId) {
       require(registeredDrones[_droneId].hasActivePlan == true, 'This mission RID is not active or invalid.');
    //return the insurance - panalties + rewards

    msg.sender.transfer( insuranceFee - registeredDrones[_droneId].panalties + registeredDrones[_droneId].rewards);
    requestsPerOwner[msg.sender]--;
    registeredDrones[_droneId].rewards=0;
    registeredDrones[_droneId].panalties=0;
 //   emit missionComplete(_missionRID);
    registeredDrones[_droneId].hasActivePlan=false;

    delete(missionPlan[_droneId]);
   }
   
}