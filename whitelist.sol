// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.6.11;

contract Whitelist {
    
    address owner;

    enum addressStatus { Default, Blacklist, Whitelist }

    event Defaulted(address _address);
    event Whitelisted(address _address);
    event Blacklisted(address _address);
    
    constructor () public {
        owner = msg.sender;
    }

    mapping (address => addressStatus) public list;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
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

    function addToDefault(address _address) public onlyOwner {
        require(list[_address] != addressStatus.Default, "Address already default");
        list[_address] = addressStatus.Default;
        emit Defaulted(_address);
    }

/*    struct Person {
        string name;
        uint age;
    }
    Person[] public persons;
    function addPerson(string memory _name, uint _age) public {
        persons.push(Person(_name, _age));
    }
    function removePerson() public {
        persons.pop();        
    }
*/
    
}
