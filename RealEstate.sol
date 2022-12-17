//SPDX-License-Identifier:MIT

pragma solidity ^0.8.9;

contract realEstate{

    string public projectName;
    uint public totalFlats;
    uint public  soldFlats;
    uint public flatPrice;
    address payable public owner;
    uint public totalBuyers;
    uint public totalVotes;
    uint public projectEndTime;
    uint public votingEndTime;
    bool public fundClaimed;


    struct buyer{

        address payable buyerAddress;
        uint totalAmtPaid;
        uint amtRemaining;
        bool fundClaimed;

}

    buyer[] public buyerDetails;

    mapping(address => uint) buyerDetailsIndex;

    mapping(address => bool) public voted;

    mapping(address => bool) public alreadyBuyer;


constructor(string memory _projectName , uint _flatPrice , uint _totalFlats , uint _projectEndTime , uint _votingEndTime){

    owner = payable(msg.sender);
    projectName = _projectName;
    flatPrice = _flatPrice;
    totalFlats = _totalFlats;
    projectEndTime = block.timestamp + _projectEndTime;
    votingEndTime = block.timestamp + _votingEndTime;

}



function buyFlat() payable external{

    require(msg.sender != owner,"Owner Cannot Buy Its Own Flat");

    require(projectEndTime > block.timestamp,"Project Has Ended");

    require(flatPrice >= msg.value,"You Cannot Send Amount More Than the Actual Price");

    require(msg.value > 1 ether,"Amount must be more than 1 ether");
    
    require(totalFlats > soldFlats,"Sorry Flats Are Not Available");

    require(alreadyBuyer[msg.sender] == false,"You Can Buy Only One Flat");


    buyer memory _buyer = buyer({

        buyerAddress : payable(msg.sender),
        totalAmtPaid : msg.value,
        amtRemaining : flatPrice - msg.value,
        fundClaimed : false

    });

    soldFlats++;
    totalBuyers++;
    alreadyBuyer[msg.sender] = true;

    buyerDetails.push(_buyer);

  
}


function depositFund() payable external{


    require(msg.sender != owner,"Owner Cannot Deposit Fund");

    require(block.timestamp > projectEndTime,"Project Has Already Ended");

    require(alreadyBuyer[msg.sender] == true,"You Should Be A Buyer To Deposit Fund");

    require(msg.value > 0,"You Cannot Send 0 Amount Of Money");

    uint index = buyerDetailsIndex[msg.sender];

    buyer memory _buyer = buyerDetails[index];

    require(_buyer.amtRemaining >= msg.value,"You Cannot Send The Amount More Than The Price");

    buyerDetails[index].totalAmtPaid -= msg.value;

    buyerDetails[index].amtRemaining += msg.value;

}

function putVote() external{

    require(msg.sender != owner,"Owner Cannot Vote");

    require(alreadyBuyer[msg.sender] == true,"You Cannot Vote As You Are Not A Buyer");

    require(block.timestamp > projectEndTime,"Project Has Not Ended Yet,You Can Only Vote When The Project Is Over");

    require(votingEndTime > block.timestamp,"Voting Time Has Ended Now");

    require(voted[msg.sender] == false,"You Can Vote Only One Time");

    totalVotes++;

    voted[msg.sender] = true;

}

function fundClaimByUser() external {

    require(msg.sender != owner,"Owner Cannot Call This Function");

    require(alreadyBuyer[msg.sender] == true,"You Should Be A Buyer To Claim The Fund");

    require(block.timestamp > projectEndTime,"Project Has Not Ended Yet");

    require(block.timestamp > votingEndTime,"Voting Time Has Not Ended Yet");

    require(totalVotes < totalBuyers/2,"Majority Doesnt Supports You");

    uint index = buyerDetailsIndex[msg.sender];

    require(buyerDetails[index].fundClaimed == false,"You Have Already Claimed The Fund");

    uint amount = buyerDetails[index].totalAmtPaid;

    address payable buyerAddress = buyerDetails[index].buyerAddress;

    buyerDetails[index].totalAmtPaid = 0;

    buyerDetails[index].fundClaimed = true;

    buyerAddress.transfer(amount);

}

function fundClaimByOwner() external {

    require(msg.sender == owner,"Only Owner Can Access This function");

    require(block.timestamp > projectEndTime,"Project Has Not Ended Yet");

    require(block.timestamp > votingEndTime,"Voting Has Not Ended Yet");

    require(totalVotes > totalBuyers/2,"Majority Doesnt Supports You");

    require(fundClaimed == false,"You Have Already Claimed The Fund");

    uint amount = address(this).balance;

    fundClaimed = true;

    owner.transfer(amount);

}

}