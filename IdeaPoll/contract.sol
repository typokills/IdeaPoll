pragma solidity >= 0.4.24;

contract Lottery {

  address private owner;
  uint private number;

  //Model an Idea
  struct Idea {
    uint id;
    string details;
    uint voteCount;
  }

  event votedIdea(
    uint id,
    string details,
    uint voteCount
  );


  //Winning Idea
  string winningIdea;

  //Store non-staff accounts that have voted
  mapping(address => bool) public voters;

  //Add or View Ideas
  mapping (uint => Idea) unconfirmedIdeas;
  mapping(uint => Idea) confirmedIdeas;

  //Staff account with admin rights
  mapping(address => bool) public staffAccount;

  //Resident accounts who were pre-registered
  mapping(address => bool) public verifiedAcc; // address of accounts to verify if they can vote

  //Store counts of the different ideas
  uint public confirmedIdeaCount;
  uint public unconfirmedIdeaCount;
  
  //Duration for opencall for ideas period
  uint public expiration;
  uint public contractExpiration;
  mapping(uint => Idea) public Ideas;

  event confirmedIdeaCreated(
    uint id,
    string details,
    uint voteCount);
  event votedIdea(
    uint voteCount);

  event newResident(
    address secret
  );

  // Constructor for the contract
  constructor() public{
    // Add government account to the staffAccount list
    owner = msg.sender;
    
    staffAccount[msg.sender] = true;
    expiration = 1000;
    contractExpiration = 10000;
    staffAddIdea("Test Idea");
    staffAddUnconfirmedIdea("Test Unconfirmed Idea");
    vote(1);
  }

  //Staff has the ability to extend the duration of the opencall (DONE)
  function extend(uint duration) public {
    require(staffAccount[msg.sender] == true);
    require (contractExpiration > 0);
    expiration = expiration + duration;
  }

  // Returns duration left  (DONE)
  function getExpiration() view public returns (uint){
    return expiration;
  }

  // For staff to add resident's address before the poll to allow them to vote (DONE)
  function addVerified(address _newresident) public{
    require(staffAccount[msg.sender] == true);
    require (contractExpiration > 0);
    verifiedAcc[_newresident] = true;
    voters[_newresident] = false;

    emit newResident(_newresident); 
  }

  // Checks if verified address has true Bool (DONE)
  function callVerified(address resident)view public returns (bool){ 
    return verifiedAcc[resident];
  }

  // Checks # confirmed ideas (DONE)
  function getConfirmedIdeaCount() view public returns (uint){
    return confirmedIdeaCount;
  }

  // Checks # unconfirmed ideas (DONE)
  function getUnconfirmedIdeaCount() view public returns (uint){
    return unconfirmedIdeaCount;
  }

  //Ideas added by the staff are automatically confirmed (DONE)
  function staffAddIdea(string memory _newIdea) public {
    require(staffAccount[msg.sender] == true);
    require (contractExpiration > 0);
    confirmedIdeaCount ++;
    confirmedIdeas[confirmedIdeaCount] = Idea(confirmedIdeaCount, _newIdea, 0);
    emit confirmedIdeaCreated(confirmedIdeaCount, _newIdea, 0);
  }

  //For Staff to Test unconfirmedIdea functions (DONE)
  function staffAddUnconfirmedIdea(string memory _newIdea) public {
    require(staffAccount[msg.sender] == true);
    unconfirmedIdeaCount ++;
    unconfirmedIdeas[unconfirmedIdeaCount] = Idea(unconfirmedIdeaCount, _newIdea, 0);
    emit confirmedIdeaCreated(confirmedIdeaCount, _newIdea, 0);
  }

  //Ideas added by residents need to be confirmed by the staff (DONE)
  function residentAddIdea(string memory _newIdea) public{
    require(verifiedAcc[msg.sender]==true);
    require(expiration > 0);
    require (contractExpiration > 0);
    require(unconfirmedIdeaCount < 9); // Ensures residents can only submit 9 ideas
    
    unconfirmedIdeaCount ++;
    unconfirmedIdeas[unconfirmedIdeaCount] = Idea(unconfirmedIdeaCount,_newIdea,0);
  }

  //Function for staff to approve unconfirmed ideas (DONE)
  function approveIdea(uint index) public {
    require(staffAccount[msg.sender] == true);
    require(confirmedIdeaCount < 10); //Ensures only 10 confirmed ideas
    require (contractExpiration > 0);

    confirmedIdeaCount ++;
    confirmedIdeas[confirmedIdeaCount] = unconfirmedIdeas[index];

    unconfirmedIdeaCount --;
    delete unconfirmedIdeas[index];
  }

  // Checks votes for a CONFIRMED IDEA (DONE)
  function getVotes(uint index) view public returns(uint){
    return confirmedIdeas[index].voteCount;
  }

  //Function to allow residents to vote on their favourite idea (DONE)
  function vote(uint indexChoice) public{
    require(voters[msg.sender] == false);
    require (contractExpiration > 0);
    voters[msg.sender] = true;

    confirmedIdeas[indexChoice].voteCount ++;

    emit votedIdea(confirmedIdeas[indexChoice].voteCount);
  }

  //Allows the staff to close the poll and not accept any more votes (DONE)
  function closePoll() public{
    require(staffAccount[msg.sender] == true);
    require (contractExpiration > 0);
    contractExpiration = 0;
    expiration = 0;
  }

}
