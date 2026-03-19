// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract ReentrancyVault {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        // VULNERABILITY: external call BEFORE state update
        (bool success, ) = payable(msg.sender).call{ value: amount }("");
        require(success, "Transfer failed");

        balances[msg.sender] = 0; // too late
    }

    function getBalances() public view returns (uint256) {
        return address(this).balance;
    }
}