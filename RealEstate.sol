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
    bool public fundClaimed


    struct buyer{

        address payable buyer;
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

    require(block.timestamp > projectEndTime,"Project Has Ended");

    require(msg.value > 1 ether,"You Cannot Send Less Than 1 Ether Of Amount ");
    
    require(totalFlats > soldFlats,"Sorry Flats Are Not Available");

    require(alreadyBuyer[msg.sender] == false,"You Can Buy Only One Flat");


    buyer memory _buyer = buyer({

        buyer : payable(msg.sender),
        totalAmtPaid : msg.value;
        amtRemaining : flatPrice - msg.value;
        fundClaimed : false

    })

    soldFlats++;
    totalBuyers++;

    buyerDetails.push(_buyer);

    alreadyBuyer[msg.sender] = true;


}





}