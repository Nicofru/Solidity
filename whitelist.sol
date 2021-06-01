// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.6.11;

contract Whitelist {
    
    struct Person {
        string name;
        uint age;
    }

    mapping (address => bool) public whitelist;
    Person[] public people;

    event Authorized(address _address);
    
    function addPerson(string memory _name, uint _age) public {
        people.push(Person(_name, _age));
    }

    function removePerson() public {
        people.pop();        
    }

    function authorize(address _address) public {
        whitelist[_address] = true;
        emit Authorized(_address);
    }
}
