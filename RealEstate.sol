//SPDX-License-Identifier:MIT

pragma solidity ^0.8.9;

contract realEstate{

//Declaring Required State Variables.

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

//Declaring The Struct To Store Buyer Details. 

    struct buyer{

        address payable buyerAddress;
        uint totalAmtPaid;
        uint amtRemaining;
        bool fundClaimed;

}

    buyer[] public buyerDetails;  //Making A Dynamic Array From Struct To Store All Buyers Details.

    mapping(address => uint) buyerDetailsIndex; //Declaring Mapping To Access The Index Value.

    mapping(address => bool) public voted;  //Declaring Mapping To Check The Voting Status Of The Buyer.

    mapping(address => bool) public alreadyBuyer;   //Declaring Mapping To Check Whether Buyer Has Already Buy A Flat Or Not.

//Declaring Constructor To Initialise Values of Some State Variables At The Time Of Deployment. 

constructor(string memory _projectName , uint _flatPrice , uint _totalFlats , uint _projectEndTime , uint _votingEndTime){

    owner = payable(msg.sender);
    projectName = _projectName;
    flatPrice = _flatPrice;
    totalFlats = _totalFlats;
    projectEndTime = block.timestamp + _projectEndTime;
    votingEndTime = block.timestamp + _votingEndTime;

}

//Making A Function Through Which User Can Buy A Flat.

function buyFlat() payable external{

    require(msg.sender != owner,"Owner Cannot Buy Its Own Flat");    

    require(projectEndTime > block.timestamp,"Project Has Ended");  //I

    require(flatPrice >= msg.value,"You Cannot Send Amount More Than the Actual Price");

    require(msg.value > 1 ether,"Amount must be more than 1 ether");
    
    require(totalFlats > soldFlats,"Sorry Flats Are Not Available");

    require(alreadyBuyer[msg.sender] == false,"You Can Buy Only One Flat"); //Checking Whether The Buyer Has Already Bought A Flat Or Not.

//Storing The Struct Into A Temporary Variable And Then Storing All The Details Of The Buyer Into That Variable.

    buyer memory _buyer = buyer({   

        buyerAddress : payable(msg.sender),
        totalAmtPaid : msg.value,
        amtRemaining : flatPrice - msg.value,
        fundClaimed : false

    });

    soldFlats++;    //Increasing The soldFlats Count. 
    totalBuyers++;  //Increasing The totalBuyers Count.
    alreadyBuyer[msg.sender] = true;    //Setting alreadyBuyer To True,So That We Can Know That This Person Is Already A Buyer.

    buyerDetails.push(_buyer);

  
}

//Making A Function To Deposit The Fund/Remaining Money Of The Flat.

function depositFund() payable external{


    require(msg.sender != owner,"Owner Cannot Deposit Fund");

    require(block.timestamp > projectEndTime,"Project Has Already Ended");

    require(alreadyBuyer[msg.sender] == true,"You Should Be A Buyer To Deposit Fund");

    require(msg.value > 0,"You Cannot Send 0 Amount Of Money");

    uint index = buyerDetailsIndex[msg.sender]; //Taking The Index Of The Buyer To Access Its Details From The Array.

    buyer memory _buyer = buyerDetails[index];  //Storing The Struct Into A Temporary Variable And Also Storing The Details Of The Buyer We Stored Inside The Array.

    require(_buyer.amtRemaining >= msg.value,"You Cannot Send The Amount More Than The Price");

    buyerDetails[index].totalAmtPaid += msg.value;  //Adding The Amount We Send Into The totalAmtPaid Variable,This Means We Have Paid This Much Total Amount Till Yet. 

    buyerDetails[index].amtRemaining -= msg.value;  //Deducting The Amount We Send From The amtRemaining Variable,This Means This Is The Remaining Amount We Have To Pay.

}

//Making A Function putVote Through Which Buyer Can Vote. 

function putVote() external{

    require(msg.sender != owner,"Owner Cannot Vote");

    require(alreadyBuyer[msg.sender] == true,"You Cannot Vote As You Are Not A Buyer");

    require(block.timestamp > projectEndTime,"Project Has Not Ended Yet,You Can Only Vote When The Project Is Over");

    require(votingEndTime > block.timestamp,"Voting Time Has Ended Now");

    require(voted[msg.sender] == false,"You Can Vote Only One Time");   //Checking Whether The Buyer Has Already Voted Or Not.

    totalVotes++;   //Increasing The totalVotes Count.

    voted[msg.sender] = true;   //Setting Voted To True,So That We Can Know That This Person Has Already Put A Vote.

}

//Making fundClaimByUser Through Which Buyer Can Claim His Fund/Money Back.

function fundClaimByUser() external {

    require(msg.sender != owner,"Owner Cannot Call This Function");

    require(alreadyBuyer[msg.sender] == true,"You Should Be A Buyer To Claim The Fund");

    //Buyer Can Only Claim His/Her Fund/Money Only When Both Project And Voting Time Has Ended.

    require(block.timestamp > projectEndTime,"Project Has Not Ended Yet");

    require(block.timestamp > votingEndTime,"Voting Time Has Not Ended Yet");

    require(totalVotes < totalBuyers/2,"Majority Doesnt Supports You");  //If The totalVotes Are less than 50% Of Buyers,Only Then Buyers Can Claim Their Money Back.

    uint index = buyerDetailsIndex[msg.sender]; //Taking The Index Of The Buyer To Access Its Details From The Array.

    require(buyerDetails[index].fundClaimed == false,"You Have Already Claimed The Fund"); //Checking If The Buyer Has Already Claim The Fund Or Not.

    uint amount = buyerDetails[index].totalAmtPaid; //Taking The totalAmtPaid By A particular Buyer Into A Variable

    address payable buyerAddress = buyerDetails[index].buyerAddress;  //Taking The Address Of The Buyer Through The Details We Stored Inside The Array.

    buyerDetails[index].totalAmtPaid = 0;   //Making The totalAmtPaid By The User 0.

    buyerDetails[index].fundClaimed = true; //Setting The Particular Buyer's fundClaimed Status To True So That We Can Know That This Buyer Has Already Claimed His/Her Fund/Money.

    buyerAddress.transfer(amount);  //Transferring The Fund Of That Particular Buyer Into Its Account.

}

//Making A Function Through Which Owner Can Claim Money Of His/Her Sold Flats.

function fundClaimByOwner() external {

    require(msg.sender == owner,"Only Owner Can Access This function");
    
    //Buyer Can Only Claim His/Her Fund/Money Only When Both Project And Voting Time Has Ended.

    require(block.timestamp > projectEndTime,"Project Has Not Ended Yet");

    require(block.timestamp > votingEndTime,"Voting Has Not Ended Yet");

    require(totalVotes > totalBuyers/2,"Majority Doesnt Supports You"); //If totalVotes Are More Than 50% Of Buyers,Only Then Owner Can Claim His/Her Fund/Money.

    require(fundClaimed == false,"You Have Already Claimed The Fund");

    uint amount = address(this).balance;   //Taking The Balance/Money Of The Contract Into A Variable.

    fundClaimed = true; //Setting The fundClaimed To True,So That We Can Know that The Owner Has ALready Claim His/Her Fund/Money.

    owner.transfer(amount); //Transferring The Amount To Owner's Address.

}

}