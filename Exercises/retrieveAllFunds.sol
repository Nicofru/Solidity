// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.1;

contract sendEth {

    address public _owner;
    uint public _initialTime;
    
    constructor () payable {
        _owner = msg.sender;
        _initialTime = block.timestamp;
    }

    function retrieveAllFunds() external {
        require(msg.sender == _owner, "Caller is not the owner");
        require(block.timestamp >= (_initialTime + 1 weeks), "Too early to retrieve funds");
        payable(_owner).transfer(address(this).balance);        
    }
 
   function sendTransac(address payable dest) public payable returns (bool){
       dest.transfer(250);
       return true;
   }   
   function getBalance(address dest) public view returns(uint){
       return dest.balance;   
   }
   function getBalanceContract() public view returns(uint){
       return address(this).balance;   
   }
}