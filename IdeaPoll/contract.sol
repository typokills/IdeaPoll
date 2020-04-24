pragma solidity >= 0.4.24;

contract Lottery {

    address private owner;
    uint private number;


    function setNumber(uint _number) public {
        number = _number;
    }

    function getNumber() view public returns(uint) {
        return(number);
    }

    function getOwner() view public returns(address){
        return(owner);
    }

    //Model an Idea
  struct Idea {
		uint id;
		string details;
		uint voteCount;
	}

  //Store non-staff accounts that have voted
  mapping(address => bool) public voters;

  //Add or View Ideas
  mapping (uint => Idea) unconfirmedIdeas;
  mapping(uint => Idea) confirmedIdeas;
  Idea winningIdea;

  //Staff account with admin rights
  mapping(address => bool) public staffAccount;

  //Resident accounts who were pre-registered
  mapping(address => bool) public verifiedAcc; // address of accounts to verify if they can vote

  //Store counts of the different ideas
  uint public confirmedIdeaCount;
  uint public unconfirmedIdeaCount;
  
  //Duration for opencall for ideas period
  uint public expiration;

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

  constructor() public{
    // Add government account to the staffAccount list
    owner = msg.sender;
    
    staffAccount[msg.sender] = true;
    expiration = 1000;
    staffAddIdea("Test Idea");
    vote(1);
  }

  //Staff has the ability to extend the duration of the opencall (DONE)
  function extend(uint duration) public {
    require(staffAccount[msg.sender] == true);

    expiration = expiration + duration;
  }

  // Returns duration left  (DONE)
  function getExpiration() view public returns (uint){
    return expiration;
  }

  // For staff to add resident's address before the poll to allow them to vote (DONE)
  function addVerified(address _newresident) public{
    require(staffAccount[msg.sender] == true);

    verifiedAcc[_newresident] = true;

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
    //require(staffAccount[msg.sender] == true);
    confirmedIdeaCount ++;
    confirmedIdeas[confirmedIdeaCount] = Idea(confirmedIdeaCount, _newIdea, 0);
    emit confirmedIdeaCreated(confirmedIdeaCount, _newIdea, 0);
  }

  //Ideas added by residents need to be confirmed by the staff
  function residentAddIdea(string memory _newIdea) public{
    require(verifiedAcc[msg.sender]==true);
    require(now <= expiration);
    require(unconfirmedIdeaCount < 9); // Ensures residents can only submit 9 ideas
    unconfirmedIdeaCount ++;
    unconfirmedIdeas[unconfirmedIdeaCount] = Idea(unconfirmedIdeaCount,_newIdea,0);
  }
    
  //Function for staff to approve unconfirmed ideas
  function approveIdea(uint index) private {
    require(staffAccount[msg.sender] == true);
    require(confirmedIdeaCount < 10); //Ensures only 10 confirmed ideas

    confirmedIdeaCount ++;
    confirmedIdeas[confirmedIdeaCount] = unconfirmedIdeas[index];

    unconfirmedIdeaCount --;
    delete unconfirmedIdeas[index];
  }

  // Checks votes for a CONFIRMED IDEA
  function getVotes(uint index) view public returns(uint){
    return confirmedIdeas[index].voteCount;
  }

  event votedIdea(
    uint id,
    string details,
    uint voteCount);
  
  //Function to allow residents to vote on their favourite idea
  function vote(uint indexChoice) public{
    //require(voters[msg.sender] == false);

    voters[msg.sender] = true;

    confirmedIdeas[indexChoice].voteCount ++;

    emit votedIdea(confirmedIdeas[indexChoice].voteCount);
  }

  //Allows the staff to close the poll and not accept any more votes
  function closePoll() public{
    require(staffAccount[msg.sender] == true);

  }

}
