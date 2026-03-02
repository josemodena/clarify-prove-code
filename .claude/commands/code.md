# /code — Implementation from Verified Specification

Generate an implementation derived from the verified Dafny specification.

## Prerequisites

- `PROOF.md` must exist (run `/prove` first).
- `proof/*.dfy` files must verify cleanly with `dafny verify`.

## Steps

1. **Confirm target language** — ask the user which language to use if not already specified.
   Refer to the supported tiers in `CLAUDE.md`. Reject Zig.

2. **Read the Dafny spec** — understand the verified methods, their signatures, pre/postconditions.

3. **Map Dafny constructs to target language**:

   | Dafny construct       | Implementation approach                                 |
   |-----------------------|---------------------------------------------------------|
   | `requires` clause     | Validated precondition (assertion or guard + error)     |
   | `ensures` clause      | Comment + optional assertion in debug builds            |
   | `invariant`           | Comment + test coverage                                 |
   | `ghost` variable      | Omit from production code; document in comment          |
   | `datatype`            | Enum / sealed class / sum type per language idiom       |
   | `predicate`           | Boolean-returning function                              |
   | `decreases`           | Justified by loop/recursion structure in comment        |

4. **Write the implementation**:
   - Use idiomatic style for the tier of the target language
   - Annotate each function/method with a reference to the Dafny method it implements,
     e.g. `# Implements: proof/operations.dfy::Transfer`
   - Keep precondition checks at function entry points

5. **Auto-merge is OFF** — do not commit, merge, or apply changes automatically.
   Present the full diff and wait for explicit user approval before making any changes.

6. **Write tests** — generate a test file covering:
   - Each verified postcondition
   - All documented edge cases from `SPEC.md`
   - At least one test per unverified assumption in `PROOF.md`

7. **Summarise** — list what was generated, what was omitted (ghost code), and any
   manual review items the user should check before approving the diff.

## Language-Specific Notes

### Python (Tier 1)
- Use type hints throughout
- Express invariants as `assert` statements guarded by `__debug__`
- Use `dataclasses` or `NamedTuple` for Dafny datatypes
- Compatible with numpy/pandas for data science workloads

### Rust (Tier 1)
- Use `Result<T, E>` for operations with error cases
- Map invariants to `debug_assert!` macros
- Use enums for Dafny `datatype`

### TypeScript/JavaScript (Tier 1)
- Use TypeScript types to encode Dafny type constraints
- Map `requires` to runtime guards with typed errors

### Go (Tier 1)
- Return `(T, error)` pairs for operations with error cases
- Use struct methods to group related operations

### Java, C, C++ (Tier 1)
- Standard idiomatic patterns apply
- Use assertions for debug-mode invariant checking

### Tier 2 languages
- Follow the same mapping table; raise any idiomatic gaps as review items.

### Tier 3 languages
- Direct structural translation; minimal idiomatic adaptation.
- Flag all non-obvious constructs for manual review.
