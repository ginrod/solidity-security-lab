// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../contracts/05 - Integer Overflow and Underflow/VulnerableToken.sol";
import "../contracts/05 - Integer Overflow and Underflow/AttackOverflow.sol";

contract OverflowTest is Test {
    VulnerableToken public token;
    AttackOverflow public attacker;

    address victim = address(0xBEEF);
    address attackerEOA = address(0xBAD);

    function setUp() public {
        token = new VulnerableToken();

        vm.deal(victim, 10 ether);
        vm.prank(victim);
        token.deposit{ value: 10 ether }();

        vm.prank(attackerEOA);
        attacker = new AttackOverflow(address(token));
    }

    function test_underflowInflatesBalance() public {
        assertEq(token.balances(address(attacker)), 0);

        vm.prank(attackerEOA);
        attacker.attack();

        assertEq(token.balances(address(attacker)), type(uint256).max);
    }

    function test_drainVictimFunds() public {
        vm.prank(attackerEOA);
        attacker.attack();

        vm.prank(attackerEOA);
        attacker.drain(10 ether);

        assertEq(address(attacker).balance, 10 ether);
        assertEq(address(token).balance, 0);
    }
}