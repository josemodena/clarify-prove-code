---
name: code
description: "Phase 3. Transpiles verified Dafny components and generates PRD-backed code for direct components. Run after /prove passes (or immediately after /clarify if no Prove-tier components exist)."
---

# Code Protocol

## Trigger
`/code`

## Prerequisites
- `docs/PRD.md` must exist and be approved.
- For every component marked **Prove** in Section 9: `logic/<component>.dfy` must exist
  and have passed `dafny verify` with zero errors. If any Prove component lacks a verified
  spec, stop and redirect to `/prove`.
- Components marked **Direct** have no Dafny prerequisite.

## Steps

1. **Read `docs/PRD.md` Section 9** (Verification Scope). Build a list of all components
   and their tier: Prove or Direct.

2. **Confirm target language** — ask the human which language to use if not already specified.
   Refer to the supported tiers in `CLAUDE.md`. Zig is not supported.

3. **For each Prove component:**
   - Read `logic/<component>.dfy` in full.
   - Write production code to `src/<component>.*`.
   - Map every Dafny `method` to a function; every `requires` clause to an input guard;
     every `ensures` clause to a comment and, where possible, a debug-mode assertion.
   - No business logic not present in the Dafny spec may be introduced.
     If missing logic is found, stop and return to `/prove`.
   - Annotate each function with a reference to its Dafny source:
     `# Implements: logic/<component>.dfy::<MethodName>`

4. **For each Direct component:**
   - Read the relevant PRD sections (operations, invariants, edge cases).
   - Write production code to `src/<component>.*`.
   - Map every PRD operation to a function; every failure mode to an explicit return type.
   - No business logic not described in the PRD may be introduced.
   - Annotate each function with a reference to its PRD section:
     `# Implements: docs/PRD.md §<section>`

5. **Write `docs/TRACE.md`:**

   | `src/` function | Proof source | PRD requirement |
   |---|---|---|
   | `payment.transfer()` | `logic/payment.dfy::Transfer` | PRD §4.1 |
   | `dashboard.render()` | PRD direct | PRD §4.3 |
   | `auth.checkPermission()` | `logic/auth.dfy::CheckPerm` | PRD §4.2 |

   Every function in `src/` must appear in this table. No exceptions.

6. **Auto-merge is OFF.** Do not commit, merge, or apply changes automatically.
   Present the full diff and wait for explicit human approval before making any changes.

7. **Summarise.** List what was generated, distinguish Prove-backed from Direct-backed
   functions, and flag any manual review items.

## Language-Specific Notes

### Python (Tier 1)
- Use type hints throughout.
- Express invariants as `assert` statements guarded by `__debug__`.
- Use `dataclasses` or `NamedTuple` for Dafny datatypes.
- Compatible with numpy/pandas for data science workloads.

### Rust (Tier 1)
- Use `Result<T, E>` for operations with error cases.
- Map invariants to `debug_assert!` macros.
- Use enums for Dafny `datatype`.
- Apply `#![forbid(unsafe_code)]` unless unsafe is required and that requirement is
  proved in the spec.

### TypeScript/JavaScript (Tier 1)
- Use TypeScript types to encode Dafny type constraints.
- Map `requires` to runtime guards with typed errors.

### Go (Tier 1)
- Return `(T, error)` pairs for operations with error cases.
- Use struct methods to group related operations.

### Java, C, C++ (Tier 1)
- Standard idiomatic patterns apply.
- Use assertions for debug-mode invariant checking.

### Tier 2 languages
- Follow the same mapping table; raise any idiomatic gaps as review items.

### Tier 3 languages
- Direct structural translation; minimal idiomatic adaptation.
- Flag all non-obvious constructs for manual review.

## Constraints
- No new business logic in this phase. Code must be isomorphic to the spec (for Prove
  components) or traceable to a PRD operation (for Direct components).
- The traceability summary is mandatory, not optional.
- If a PRD requirement cannot be expressed in the compiled code, escalate to the human
  before proceeding.
