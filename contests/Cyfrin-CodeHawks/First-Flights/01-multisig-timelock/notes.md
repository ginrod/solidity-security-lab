# First Flight #55 — MultiSig Timelock
**Contest:** https://codehawks.cyfrin.io/c/2025-12-multisig-timelock
**Date:** December 18–25, 2025
**nSLOC:** 205

## Contract Overview
Role-based multisig wallet with dynamic timelock. Up to 5 signers, 3 confirmations required.
Timelock scales with transaction value: <1 ETH = none, 1–10 ETH = 1 day, 10–100 ETH = 2 days, >=100 ETH = 7 days.

---

## My Observations
<!-- Llenar durante la lectura. Sugerencias de qué anotar:
  - ¿Quién puede llamar cada función? (access control)
  - ¿Dónde se modifica estado antes/después de llamadas externas?
  - ¿Qué invariantes debe mantener el contrato?
  - ¿Hay casos límite en los checks (==, >=, <=)?
  - ¿Algo que el contrato asume pero no verifica?
-->

