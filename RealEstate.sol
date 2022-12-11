//SPDX-License-Identifier:MIT

pragma solidity ^0.8.9;

contract realEstate{

    string public prjectName;
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





}