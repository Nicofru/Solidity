// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Admin is Ownable {
    
    enum addressStatus { Default, Blacklist, Whitelist }

    event Whitelisted(address _address);
    event Blacklisted(address _address);

    mapping (address => addressStatus) public list;

    function isWhitelisted(address _address) public view returns (bool) {
        return list[_address] == addressStatus.Whitelist;
    }

    function isBlacklisted(address _address) public view returns (bool) {
        return list[_address] == addressStatus.Blacklist;
    }
    
    function addToWhitelist(address _address) public onlyOwner {
        require(list[_address] != addressStatus.Whitelist, "Address already whitelisted");
        list[_address] = addressStatus.Whitelist;
        emit Whitelisted(_address);
    }

    function addToBlacklist(address _address) public onlyOwner {
        require(list[_address] != addressStatus.Blacklist, "Address already blacklisted");
        list[_address] = addressStatus.Blacklist;
        emit Blacklisted(_address);
    }
}
