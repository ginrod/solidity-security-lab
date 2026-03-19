// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

interface IPool {
    function getPrice() external view returns (uint256);
}

// VULNERABILITY: uses spot price from manipulable pool as oracle
contract VulnerableLending {
    IPool public oracle;
    mapping(address => uint256) public collateral; // ETH deposited
    mapping(address => uint256) public borrowed; // USD borrowed

    constructor(address _pool) {
        oracle = IPool(_pool);
    }

    // Deposit ETH as collateral
    function depositCollateral() public payable {
        collateral[msg.sender] += msg.value;
    }

    function borrow(uint256 usdAmount) public {
        uint256 price = oracle.getPrice(); // spot price MANIPULABLE
        uint256 collateralValue = collateral[msg.sender] * price;
        uint256 maxBorrow = (collateralValue * 80) / 100; // 80% LTV

        require(borrowed[msg.sender] + usdAmount <= maxBorrow, "Undercollateralized");
        borrowed[msg.sender] += usdAmount;
    }

    function getMaxBorrow(address user) public view returns (uint256) {
        uint256 price = oracle.getPrice();
        return (collateral[user] * price * 80) / 100;
    }
}