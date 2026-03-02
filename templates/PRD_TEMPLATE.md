# PRD: [Module Name]

**Status:** Draft / Approved
**Phase:** define
**Date:** YYYY-MM-DD
**Target Language:** [e.g. Python — must be a Dafny compile target if any Prove-tier components exist: py, go, java, js, cs, rs]

---

## 1. Intent

_One paragraph. What does this module do, and why does it exist?_

---

## 2. Actors and Boundaries

_Who or what interacts with this module?_

| Actor | Interaction | Trust Level |
|---|---|---|
| e.g. API caller | Submits transfer request | Untrusted |
| e.g. Internal scheduler | Triggers TTL cleanup | Trusted |

---

## 3. State Invariants

_What must always be true, regardless of the sequence of operations?_

- INV-1: [e.g. The total sum of all account balances must not change during a transfer.]
- INV-2: [e.g. No item may exist in the cache with an elapsed TTL greater than 500ms.]
- INV-3: ...

---

## 4. Operations

_List every operation this module exposes._

### 4.1 [OperationName]

**Preconditions:**
- [e.g. `amount > 0`]
- [e.g. `source.balance >= amount`]

**Postconditions:**
- [e.g. `source.balance_after == source.balance_before - amount`]
- [e.g. `dest.balance_after == dest.balance_before + amount`]

**Failure modes:**
- [e.g. Returns `error.InsufficientFunds` if precondition 2 is not met.]
- [e.g. Returns `error.InvalidAmount` if precondition 1 is not met.]

---

## 5. Edge Cases

_Cases that must be explicitly handled._

- EDGE-1: [e.g. What happens if source and dest are the same account?]
- EDGE-2: [e.g. What happens if the module receives two concurrent writes?]
- EDGE-3: ...

---

## 6. Security Boundaries

- [e.g. Only authenticated users with the `TRANSFER` permission may call Operation 4.1.]
- [e.g. Amount is validated server-side; client input is never trusted.]

---

## 7. Performance Contracts

_Non-negotiable constraints on latency or resource usage. Leave blank if none._

- [e.g. Operation 4.1 must complete in < 10ms under normal load.]
- [e.g. The module may not allocate more than 1MB of heap memory.]

---

## 8. Out of Scope

_Explicit list of what this module does NOT do._

- [e.g. Currency conversion is handled by a separate module.]
- [e.g. Audit logging is the responsibility of the caller.]

---

## 9. Verification Scope

_The agent proposes a verification tier for each component. Review and adjust before
signing off — this triage determines which components go through Dafny verification
vs. direct code generation from the PRD._

| Component | Tier | Rationale |
|---|---|---|
| e.g. PaymentProcessor | Prove | Handles money; correctness failure = financial loss |
| e.g. UserDashboard | Direct | UI rendering; no state invariants to prove |
| e.g. AuthMiddleware | Prove | Security boundary; must be exhaustive |
| e.g. EmailNotifier | Direct | Side-effect only; no correctness invariants |

**Triage criteria:**
- **Prove**: financial logic, access control, data integrity, state machines with complex
  transitions, external-facing security boundaries, safety-critical behaviour.
- **Direct**: UI components, API glue, configuration loading, logging, scripts, prototypes.

---

## Human Sign-off

> Review all sections above, including the Target Language and the Verification Scope
> in Section 9. Confirm that the Target Language is a valid Dafny compile target if
> any components are marked Prove. When satisfied, reply "approved" to proceed to
> `/prove` (or directly to `/code` if no components are marked Prove).

**Approved by:** _______________
**Date:** _______________
