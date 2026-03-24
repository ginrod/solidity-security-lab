# First Flight #55 — MultiSig Timelock
**Contest:** https://codehawks.cyfrin.io/c/2025-12-multisig-timelock
**Date:** December 18–25, 2025
**nSLOC:** 205

## Contract Overview
Role-based multisig wallet with dynamic timelock. Up to 5 signers, 3 confirmations required.
Timelock scales with transaction value: <1 ETH = none, 1–10 ETH = 1 day, 10–100 ETH = 2 days, >=100 ETH = 7 days.

---

## My Observations (pre-report)

### Access control map
| Function | Restriction |
|---|---|
| `grantSigningRole` | `onlyOwner` |
| `revokeSigningRole` | `onlyOwner` |
| `proposeTransaction` | `onlyOwner` |
| `confirmTransaction` | `onlyRole(SIGNING_ROLE)` |
| `revokeConfirmation` | `onlyRole(SIGNING_ROLE)` |
| `executeTransaction` | `onlyRole(SIGNING_ROLE)` |

Two separate permission systems in use: `Ownable` and `AccessControl`.

### Findings I identified
1. **[HIGH — not validated]** Timelock bypass via `value=0` + malicious `data` payload — no delay for sub-1-ETH transactions regardless of data content.
2. **[HIGH → actually LOW]** Owner can self-revoke `SIGNING_ROLE` → can still propose but not confirm/execute → potential deadlock if signer count drops below 3.
3. **[MEDIUM → actually LOW]** Only owner can propose — signers have no proposal mechanism, single point of failure.
4. **[LOW]** No transaction cancellation mechanism — stuck transactions persist forever.

### What I missed (the real HIGH)
`revokeSigningRole()` removes the signer's role and updates `s_isSigner`, but **never touches `s_signatures` or `s_transactions[txnId].confirmations`**. Confirmations from revoked signers persist and continue counting toward quorum.

```solidity
function revokeSigningRole(address _account) external ... {
    s_isSigner[_account] = false;
    _revokeRole(SIGNING_ROLE, _account);
    // ❌ s_signatures[txnId][_account] remains true
    // ❌ s_transactions[txnId].confirmations is never decremented
}
```

Compounded by the fact that `revokeConfirmation()` requires `SIGNING_ROLE` — so a revoked signer cannot even remove their own confirmation after losing the role.

---

## Official Results (codehawks.cyfrin.io/c/2025-12-multisig-timelock/results)

### HIGH (2)
- **H-01:** Revoked signers retain valid confirmations — `revokeSigningRole()` fails to clear `s_signatures` or decrement confirmation counters on pending transactions.
- **H-02:** Zombie confirmations + no transaction expiration — stale approvals from revoked signers persist indefinitely; `_executeTransaction()` validates count only, not whether confirmers are still active.

### MEDIUM (4 — all same root cause)
All 4 medium findings are duplicates/variants of H-01: confirmations from revoked signers remain valid and count toward the 3-signature quorum.

### LOW (5 — not fully published)
Based on submissions: owner self-revoke deadlock, signers can't propose, stuck transactions below quorum, missing event fields, dual tracking system risk.

---

## Key lessons

1. **State orphan bug pattern:** When revoking permissions, always ask "what accumulated state references this permission and needs to be cleaned up?" Here: `s_signatures` + `confirmations` counter were orphaned.
2. **Severity calibration:** I called the self-revoke deadlock HIGH — it's LOW because it requires the owner to take a self-destructive action. The stale confirmation bug is HIGH because it's triggered by a routine admin action (removing a bad actor) that silently preserves their influence.
3. **My timelock bypass (value=0 + data)** was a valid observation but wasn't validated — likely because `proposeTransaction` is `onlyOwner`, so the attacker would need to control the owner key, which changes the threat model.
4. **Single root cause, many submissions:** H-01, H-02, and all 4 mediums share one root cause explored from different angles. In real contests, finding the root cause early and documenting multiple impact vectors is more valuable than finding many unrelated bugs.

