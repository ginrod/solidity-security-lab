// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title VulnerableDEX
 * @notice Simple x*y=k AMM with no slippage protection.
 * @dev VULNERABILITY: swapETHForTokens() accepts no minAmountOut parameter.
 *      A pending swap visible in the mempool can be sandwiched:
 *      attacker buys first (pushes price up), victim executes at worse
 *      price, attacker sells back for profit — all at victim's expense.
 */
contract VulnerableDEX {
    uint256 public ethReserve;
    uint256 public tokenReserve;

    mapping(address => uint256) public tokenBalances;

    event Swap(address indexed user, uint256 ethIn, uint256 tokensOut);
    event SwapBack(address indexed user, uint256 tokensIn, uint256 ethOut);

    constructor() payable {
        require(msg.value > 0, "Must seed liquidity");
        ethReserve = msg.value;
        tokenReserve = msg.value * 1000; // initial price: 1 ETH = 1000 tokens
        tokenBalances[address(this)] = tokenReserve;
    }

    // VULNERABILITY: no minAmountOut — victim accepts any amount of tokens
    // In a real DEX (Uniswap v2/v3) this parameter is the slippage guard.
    function swapETHForTokens() external payable returns (uint256 tokensOut) {
        require(msg.value > 0, "Must send ETH");

        // x * y = k: tokensOut = tokenReserve * ethIn / (ethReserve + ethIn)
        tokensOut = (tokenReserve * msg.value) / (ethReserve + msg.value);

        ethReserve += msg.value;
        tokenReserve -= tokensOut;
        tokenBalances[msg.sender] += tokensOut;
        tokenBalances[address(this)] -= tokensOut;

        emit Swap(msg.sender, msg.value, tokensOut);
    }

    function swapTokensForETH(uint256 tokensIn) external returns (uint256 ethOut) {
        require(tokensIn > 0, "Must send tokens");
        require(tokenBalances[msg.sender] >= tokensIn, "Insufficient balance");

        // ethOut = ethReserve * tokensIn / (tokenReserve + tokensIn)
        ethOut = (ethReserve * tokensIn) / (tokenReserve + tokensIn);

        tokenReserve += tokensIn;
        ethReserve -= ethOut;
        tokenBalances[msg.sender] -= tokensIn;
        tokenBalances[address(this)] += tokensIn;

        payable(msg.sender).transfer(ethOut);

        emit SwapBack(msg.sender, tokensIn, ethOut);
    }

    /// @notice Preview output for a given input (read-only, does not update state)
    function getAmountOut(uint256 amountIn, bool ethToToken) external view returns (uint256) {
        if (ethToToken) {
            return (tokenReserve * amountIn) / (ethReserve + amountIn);
        } else {
            return (ethReserve * amountIn) / (tokenReserve + amountIn);
        }
    }
}
