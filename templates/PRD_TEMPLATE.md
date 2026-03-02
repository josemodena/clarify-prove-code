# PRD: [Module Name]

**Status:** Draft / Approved
**Phase:** clarify
**Date:** YYYY-MM-DD

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

## Human Sign-off

> Review the sections above. When satisfied, reply "approved" to proceed to `/prove`.

**Approved by:** _______________
**Date:** _______________
