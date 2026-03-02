# Language Support

## Tier 1 — Full Support

- Idiomatic output in the target language's style
- Complete mapping of all Dafny constructs to language equivalents
- Tests generated using the language's standard testing framework
- Inline proof annotations linked to verified Dafny methods

## Tier 2 — Standard Support

- Spec-to-code mapping for all Dafny constructs
- Best-effort idiomatic output (some constructs may be non-idiomatic)
- Tests generated; may require minor manual adjustment

## Tier 3 — Basic Support

- Direct structural translation of Dafny constructs
- Minimal idiomatic adaptation
- All non-obvious constructs flagged for manual review in the diff

Any language not explicitly assigned to Tier 1 or Tier 2 falls into Tier 3, **except Zig, which is not supported at any tier**.

## Requesting a Language

If your language is Tier 3 and the output is poor, open an issue describing
the specific Dafny constructs that didn't translate well. Tier promotions are
considered when there is a concrete spec-to-idiom mapping to implement.
