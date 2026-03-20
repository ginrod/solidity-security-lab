// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

interface IPool {
    function getPrice() external view returns (uint256);
}

contract VulnerableLending {
    IPool public oracle;
    mapping(address => uint256) public collateral;
    mapping(address => uint256) public borrowed;

    constructor(address _pool) {
        oracle = IPool(_pool);
    }

    function depositCollateral() public payable {
        collateral[msg.sender] += msg.value;
    }

    function borrow(uint256 usdAmount) public {
        uint256 price = oracle.getPrice();
        uint256 collateralValue = collateral[msg.sender] * price;
        uint256 maxBorrow = (collateralValue * 80) / 100;

        require(borrowed[msg.sender] + usdAmount <= maxBorrow, "Undercollateralized");
        borrowed[msg.sender] += usdAmount;
    }

    function getMaxBorrow(address user) public view returns (uint256) {
        uint256 price = oracle.getPrice();
        return (collateral[user] * price * 80) / 100;
    }
}
