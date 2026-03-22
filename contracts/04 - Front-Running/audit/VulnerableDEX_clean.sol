// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

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

    function swapETHForTokens() external payable returns (uint256 tokensOut) {
        require(msg.value > 0, "Must send ETH");

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

        ethOut = (ethReserve * tokensIn) / (tokenReserve + tokensIn);

        tokenReserve += tokensIn;
        ethReserve -= ethOut;
        tokenBalances[msg.sender] -= tokensIn;
        tokenBalances[address(this)] += tokensIn;

        payable(msg.sender).transfer(ethOut);

        emit SwapBack(msg.sender, tokensIn, ethOut);

    }

    function getAmountOut(uint256 amountIn, bool ethToToken) external view returns (uint256) {
        if (ethToToken) {
            return (tokenReserve * amountIn) / (ethReserve + amountIn);
        }
        else {
            return (ethReserve * amountIn) / (tokenReserve + amountIn);
        }
    }
}