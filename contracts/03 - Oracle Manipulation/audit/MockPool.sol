// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

contract MockPool {
    uint256 public ethReserve = 100 ether;
    uint256 public usdReserve = 300_000 ether;

    function getPrice() public view returns (uint256) {
        return usdReserve / ethReserve;
    }

    function buyETH(uint256 usdIn) public returns (uint256 ethOut) {
        ethOut = (ethReserve * usdIn) / (usdReserve + usdIn);
        ethReserve -= ethOut;
        usdReserve += usdIn;
    }

    function sellETH(uint256 ethIn) public returns (uint256 usdOut) {
        usdOut = (usdReserve * ethIn) / (ethReserve + ethIn);
        usdReserve -= usdOut;
        ethReserve += ethIn;
    }
}
