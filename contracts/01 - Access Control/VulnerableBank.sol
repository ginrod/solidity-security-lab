// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

contract VulnerableBank {
    address public owner;
    mapping(address => uint256) public balances;

    constructor() {
        owner = msg.sender; // who deploys is the owner
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // THIS IS THE VULNERABILITY: anyone can call this
    function withdraw(address _to) public {
        uint256 amount = balances[_to];
        balances[_to] = 0;
        payable(msg.sender).transfer(amount);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}