# [H-01] Unauthorized Withdrawal — Any caller can drain other users' funds

## Severity
High

## Description
The `withdraw` function accepts an arbitrary `_victim` address and sends
that address's deposited balance to `msg.sender`. There is no validation
that `msg.sender == _victim`, allowing any caller to steal funds deposited
by other users.

## Vulnerable Code
```solidity
function withdraw(address _victim) public {
    uint256 amount = balances[_victim];
    balances[_victim] = 0;
    payable(msg.sender).transfer(amount); // attacker receives victim's ETH
}
```

## Attack Scenario
1. Victim (wallet1) deposits 1 ETH → `balances[wallet1] = 1 ETH`
2. Attacker (wallet2) calls `withdraw(wallet1_address)`
3. Contract zeroes `balances[wallet1]` and transfers 1 ETH to wallet2
4. Attacker receives 1 ETH they never deposited

## Impact
Complete loss of funds for any depositor. A single transaction drains
any user's balance with no preconditions.

## Recommendation
Remove the `_victim` parameter. Use `msg.sender` as both the balance
source and the recipient:

```solidity
function withdraw() public {
    uint256 amount = balances[msg.sender];
    balances[msg.sender] = 0;
    payable(msg.sender).transfer(amount);
}
```

## References
- OWASP Smart Contract Top 10 (2025) — SC01 Improper Access Control: https://owasp.org/www-project-smart-contract-top-10/2025/en/src/SC01-access-control.html
- OpenZeppelin Access Control Docs: https://docs.openzeppelin.com/contracts/5.x/api/access
- SWC-105: Unprotected Ether Withdrawal (archived): https://swcregistry.io/docs/SWC-105
