# solidity-security-lab

Hands-on practice repo for Web3 smart contract security.
Focus: identifying, exploiting, and reporting vulnerabilities in Solidity contracts
using the same format as real audit competitions (Code4rena / Immunefi).

Each vulnerability is covered end-to-end:
- Vulnerable contract written and deployed in Remix
- Attack contract or exploit steps documented
- Finding written in standard audit report format

---

## Vulnerabilities Covered

| ID | Title | Severity | Contract |
|----|-------|----------|----------|
| H-01 | Unauthorized Withdrawal — missing access control | High | [VulnerableBank.sol](contracts/VulnerableBank.sol) |
| C-02 | Reentrancy — state updated after external call | Critical | [ReentrancyVault.sol](contracts/ReentrancyVault.sol) |

---

## Structure

```
/contracts      — vulnerable contracts and attack contracts used in exercises
/findings       — reports in Code4rena/Immunefi format
README.md
```

---

## Tools Used

- Remix IDE — contract deployment and exploit execution
- AuditAgent (Nethermind) — AI-assisted vulnerability scanning and finding triage
