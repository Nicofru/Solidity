// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.11;

contract getContractBalance {
    
    function getBalance() external view returns (uint){
        return address(0xb2f55315C465297A5926795d5Bb94f985209398E).balance;
    }
}
