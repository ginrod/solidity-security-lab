// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

// Simulates a liquidity pool whose price can be moved by large trades
contract MockPool {
    uint256 public ethReserve = 100 ether;
    uint256 public usdReserve = 300_000 ether; // 1 ETH = 3000 USD initially

    // Returns spot price: how many USD per ETH
    function getPrice() public view returns (uint256) {
        return usdReserve / ethReserve;
    }

    // Simulates buying ETH with USD, which moves the price up
    function buyETH(uint256 usdIn) public returns (uint256 ethOut) {
        ethOut = (ethReserve * usdIn) / (usdReserve + usdIn);
        ethReserve -= ethOut;
        usdReserve += usdIn;
    }

    // Simulates selling ETH for USD, which moves the price down
    function sellETH(uint256 ethIn) public returns (uint256 usdOut) {
        usdOut = (usdReserve * ethIn) / (ethReserve + ethIn);
        usdReserve -= usdOut;
        ethReserve += ethIn;
    }
}