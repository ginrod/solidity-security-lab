# solidity-security-lab

Hands-on practice repo for Web3 smart contract security.
Focus: identifying, exploiting, and reporting vulnerabilities in Solidity contracts
using the same format as real audit competitions (Code4rena / Immunefi).

Each vulnerability is covered end-to-end:
- Vulnerable contract and attack contract written in Solidity
- Exploit verified with a Foundry PoC test
- Finding written in standard audit report format (Code4rena/Immunefi)
- AuditAgent scan with AI-assisted triage

---

## Vulnerabilities Covered

| ID | Title | Severity | Contract |
|----|-------|----------|----------|
| C-01 | Unauthorized Withdrawal — missing access control | Critical | [VulnerableBank.sol](contracts/01%20-%20Access%20Control/VulnerableBank.sol) |
| C-02 | Reentrancy — state updated after external call | Critical | [ReentrancyVault.sol](contracts/02%20-%20Reentrancy/ReentrancyVault.sol) |
| H-03 | Oracle Manipulation — spot price from AMM allows inflated borrowing | High | [VulnerableLending.sol](contracts/03%20-%20Oracle%20Manipulation/VulnerableLending.sol) |
| H-04 | Front-Running — missing slippage protection enables sandwich attacks | High | [VulnerableDEX.sol](contracts/04%20-%20Front-Running/VulnerableDEX.sol) |
| H-05 | Integer Underflow — unchecked arithmetic inflates balance to 2^256-1, enabling full fund drainage | High | [VulnerableToken.sol](contracts/05%20-%20Integer%20Overflow%20and%20Underflow/VulnerableToken.sol) |

---

## AuditAgent Scans

| Scan | Contracts | Findings | False Positives | Triage |
|------|-----------|----------|-----------------|--------|
| #1 — 2026-03-19 | VulnerableBank, ReentrancyVault | 6 | 1 | [triage notes](audits/01-auditagent-2026-03-19/) |
| #2 — 2026-03-20 | MockPool, VulnerableLending | 7 | 1 | [triage notes](audits/02-auditagent-2026-03-20/triage.md) |
| #3 — 2026-03-22 | VulnerableDEX | 4 | 0 | [triage notes](audits/03-auditagent-2026-03-22/triage.md) |

Scans run without context or comments to test unbiased detection and practice triage.

---

## Structure

```
/contracts      — vulnerable contracts and attack contracts, one folder per vulnerability
/test           — Foundry PoC tests (.t.sol) that verify each exploit
/findings       — reports in Code4rena/Immunefi format
/audits         — AuditAgent scan reports and triage notes
foundry.toml    — Foundry project configuration
README.md
```

---

## Tools Used

- Foundry — test framework for PoC development and exploit verification
- AuditAgent (Nethermind) — AI-assisted vulnerability scanning
- Remix IDE — contract deployment and exploit execution (early exercises)
