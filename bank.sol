// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
    
contract Bank {

    using SafeMath for uint256;

    mapping (address => uint) _balances;

    function deposit(uint _amount) public payable {
        require(_amount == msg.value, "Please send correct amount of ether");
        _balances[msg.sender] = _balances[msg.sender].add(_amount);
    }

    function transfer(address _recipient, uint _amount) public {
        require(_balances[msg.sender] >= _amount, "Account balance is too low");
        _balances[msg.sender] = _balances[msg.sender].sub(_amount);
        _balances[_recipient] = _balances[_recipient].add(_amount);
        payable(_recipient).transfer(_amount);
    }

    function balanceOf(address _address) public view returns (uint) {
        return _balances[_address];
    }
}
