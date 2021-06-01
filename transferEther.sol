// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.6.11;

contract transferEther {
    
    function transfer(address payable _recipient) payable external {
        _recipient.transfer(msg.value);
    }
}
