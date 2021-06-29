/*
* Add license identifier
* Use latest version of solidity, preferably fix version number to avoir bugs, without the "^"
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;

contract Crowdsale {
    // Safemath features are already included from version 0.8.0, no need to declare it

    address public owner;
    address public escrow;
    uint256 public savedBalance; // no need to initiate the variable at 0, done automatically
    mapping (address => uint256) public balances;

    // using constructor() to initialize the contract
    constructor(address _escrow) {
        owner = msg.sender; // do not use tx.origin
        escrow = _escrow;
    }
 
    /*
    * Add the possibility to add funds to the contract,
    * otherwise withdrawPayments() will not be usable,
    * or get rid of the escrow and store all the funds directly on the contract
    */
    receive() external payable {}
  
    // declaring function "payable" to allow payments
    function deposit() external payable {
        require(msg.value > 0, "No funds provided");
        
        balances[msg.sender] += msg.value;
        savedBalance += msg.value;

        // preferably use call instead of send, and check return value
        (bool success, ) = payable(escrow).call{ value: msg.value }("");
        require(success, "Transfer failed.");
    }
 
    function withdrawPayments() external {
        require(balances[msg.sender] > 0, "No funds to withdraw");
        require(address(this).balance >= balances[msg.sender], "Not enough funds available");

        // no need to instantiate a variable for msg.sender
        uint256 payment = balances[msg.sender];

        // update balances before making the payment to avoid reentrancies
        savedBalance -= payment;
        balances[msg.sender] = 0;
 
        // preferably use call instead of send, and check return value
        (bool success, ) = payable(msg.sender).call{ value: payment }("");
        require(success, "Transfer failed.");
    }
    
    function getBalance() external view returns (uint) {
        return  address(this).balance;
    }
}
