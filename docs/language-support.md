# Language Support

## Tier 1 — Full Support

Full support means:
- Idiomatic output in the target language's style
- Complete mapping of all Dafny constructs to language equivalents
- Tests generated using the language's standard testing framework
- Inline proof annotations linked to verified Dafny methods

| Language | Notes |
|----------|-------|
| **Python** | Required. Explicit support for data science and ML workloads: numpy/pandas-compatible type hints, `__debug__`-guarded assertions, `dataclasses`/`NamedTuple` for algebraic types. |
| TypeScript | Strict mode; type-level encoding of Dafny type constraints. |
| JavaScript | JSDoc types; targets Node.js and browser environments. |
| Rust | `Result<T, E>` for error cases; `debug_assert!` for invariants; `enum` for `datatype`. |
| Go | `(T, error)` returns; struct methods for grouped operations. |
| Java | Checked exceptions or `Optional<T>`; `assert` in debug mode. |
| C | `assert.h` for invariants; manual memory management documented in proof annotations. |
| C++ | RAII patterns; `static_assert` where applicable; `std::expected` (C++23) for error handling. |

## Tier 2 — Standard Support

Standard support means:
- Spec-to-code mapping for all Dafny constructs
- Best-effort idiomatic output (some constructs may be non-idiomatic)
- Tests generated; may require minor manual adjustment

| Language | Notes |
|----------|-------|
| C# | Natural fit with Dafny (same .NET ecosystem); near-Tier-1 quality. |
| Kotlin | Sealed classes for `datatype`; coroutines not in scope. |
| Swift | `Result<T, Error>` for errors; value types preferred. |
| Scala | Case classes and `Either[E, T]` for algebraic types. |
| Ruby | Duck typing; invariants documented rather than enforced at runtime. |

## Tier 3 — Basic Support

Basic support means:
- Direct structural translation of Dafny constructs
- Minimal idiomatic adaptation
- All non-obvious constructs flagged for manual review in the diff

All languages not listed in Tier 1 or Tier 2 fall into Tier 3, **except Zig**.

## Explicitly Excluded

**Zig** is not supported at any tier.

## Requesting a Language

If your language is Tier 3 and the output is poor, open an issue describing
the specific Dafny constructs that didn't translate well. Tier promotions are
considered when there is a concrete spec-to-idiom mapping to implement.
