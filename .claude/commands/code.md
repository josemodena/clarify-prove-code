# /code — Implementation from Verified Specification

Generate production code for all components: isomorphic transpilation for Prove-tier
components, PRD-backed generation for Direct-tier components.

## Prerequisites

- `docs/PRD.md` must exist and be approved.
- For every component marked **Prove** in Section 9: `logic/<component>.dfy` must exist
  and have passed `dafny verify` with zero errors. If any Prove component lacks a
  verified spec, stop and redirect to `/prove`.
- Components marked **Direct** have no Dafny prerequisite.

## Steps

1. **Read `docs/PRD.md` Section 9** (Verification Scope). List all components and their
   tier (Prove or Direct).

2. **Confirm target language** — ask the human which language to use if not already specified.
   Refer to the supported tiers in `CLAUDE.md`. Zig is not supported.

3. **For each Prove component:**
   - Read `logic/<component>.dfy` in full.
   - Write production code to `src/<component>.*`.

   | Dafny construct       | Implementation approach                                |
   |-----------------------|--------------------------------------------------------|
   | `requires` clause     | Validated precondition (assertion or guard + error)    |
   | `ensures` clause      | Comment + optional assertion in debug builds           |
   | `invariant`           | Comment + test coverage                                |
   | `ghost` variable      | Omit from production; document in comment              |
   | `datatype`            | Enum / sealed class / sum type per language idiom      |
   | `predicate`           | Boolean-returning function                             |
   | `decreases`           | Justified by loop/recursion structure in comment       |

   - No business logic not present in the Dafny spec may be introduced.
   - Annotate each function: `# Implements: logic/<component>.dfy::<MethodName>`

4. **For each Direct component:**
   - Read the relevant PRD sections (operations, invariants, edge cases).
   - Write production code to `src/<component>.*`.
   - Map every PRD operation to a function; every failure mode to an explicit return type.
   - No business logic not described in the PRD may be introduced.
   - Annotate each function: `# Implements: docs/PRD.md §<section>`

5. **Write `docs/TRACE.md`:**

   | `src/` function | Proof source | PRD requirement |
   |---|---|---|
   | `payment.transfer()` | `logic/payment.dfy::Transfer` | PRD §4.1 |
   | `dashboard.render()` | PRD direct | PRD §4.3 |
   | `auth.checkPermission()` | `logic/auth.dfy::CheckPerm` | PRD §4.2 |

   Every function in `src/` must appear in this table.

6. **Auto-merge is OFF.** Do not commit, merge, or apply changes automatically.
   Present the full diff and wait for explicit human approval.

7. **Summarise** — list what was generated, distinguish Prove-backed from Direct-backed
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
- Apply `#![forbid(unsafe_code)]` unless unsafe is required and proved in the spec.

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
