# AuditAgent Scan Context — 2026-03-19

Contracts scanned: VulnerableBank.sol, ReentrancyVault.sol
Tool: AuditAgent V2 (Nethermind) — free tier

---

## 1. On what chains are the smart contracts going to be deployed?

Not intended for production. Practice contracts for vulnerability research.

## 2. Are there any limitations on values set by admins (or other roles) in the codebase or in protocols you integrate with, including restrictions on array lengths?

No admin roles or privileged addresses exist in these contracts.

## 3. Is the codebase expected to comply with any specific EIPs?

No specific EIP compliance required.

## 4. Are there any off-chain mechanisms involved in the protocol (e.g., keeper bots, arbitrage bots, etc.)?

None. Contracts are self-contained with no external dependencies.

## 5. Any design choices you made that you would like to mention?

Simple bank-style contracts handling ETH deposits and withdrawals.

## 6. Additional audit information

N/A
