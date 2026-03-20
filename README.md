# solidity-security-lab

Hands-on practice repo for Web3 smart contract security.
Focus: identifying, exploiting, and reporting vulnerabilities in Solidity contracts
using the same format as real audit competitions (Code4rena / Immunefi).

Each vulnerability is covered end-to-end:
- Vulnerable contract written and deployed in Remix
- Attack contract or exploit steps documented
- Finding written in standard audit report format
- AI-assisted scan via AuditAgent with manual triage

---

## Vulnerabilities Covered

| ID | Title | Severity | Contract |
|----|-------|----------|----------|
| C-01 | Unauthorized Withdrawal — missing access control | Critical | [VulnerableBank.sol](contracts/01%20-%20Access%20Control/VulnerableBank.sol) |
| C-02 | Reentrancy — state updated after external call | Critical | [ReentrancyVault.sol](contracts/02%20-%20Reentrancy/ReentrancyVault.sol) |
| H-03 | Oracle Manipulation — spot price from AMM allows inflated borrowing | High | [VulnerableLending.sol](contracts/03%20-%20Oracle%20Manipulation/VulnerableLending.sol) |

---

## AuditAgent Scans

| Scan | Contracts | Findings | False Positives | Triage |
|------|-----------|----------|-----------------|--------|
| #1 — 2026-03-19 | VulnerableBank, ReentrancyVault | 6 | 1 | [triage notes](audits/01-auditagent-2026-03-19/) |
| #2 — 2026-03-20 | MockPool, VulnerableLending | 7 | 1 | [triage notes](audits/02-auditagent-2026-03-20/triage.md) |

Scans run without context or comments to test unbiased detection.
Oracle manipulation (H-03) was correctly identified by AuditAgent without hints.

---

## Structure

```
/contracts      — vulnerable contracts and attack contracts used in exercises
/findings       — reports in Code4rena/Immunefi format
/audits         — AuditAgent scan reports and triage notes
README.md
```

---

## Tools Used

- Remix IDE — contract deployment and exploit execution
- AuditAgent (Nethermind) — AI-assisted vulnerability scanning
- Foundry — test framework for PoC development (in progress)
