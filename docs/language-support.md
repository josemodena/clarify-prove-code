# Language Support

Language support in clarify-prove-code works differently depending on the component tier.

---

## Prove-tier: Dafny Compiler Targets

Prove-tier components are compiled directly from the verified Dafny spec using the Dafny
compiler (`dafny translate`). No LLM translation is involved — the output is isomorphic
to the spec by construction.

The target language must be one the Dafny compiler supports:

| Language              | Dafny target code | Notes                     |
|-----------------------|-------------------|---------------------------|
| Python                | `py`              | Full support              |
| Go                    | `go`              | Full support              |
| Java                  | `java`            | Full support              |
| JavaScript/TypeScript | `js`              | Full support              |
| C#                    | `cs`              | Full support (default)    |
| Rust                  | `rs`              | Experimental              |

**C and C++ are not Dafny compile targets.** If your project uses C/C++ and has Prove-tier
components, flag this during `/define` and choose an alternative (e.g. generate a
Dafny-supported language and wrap it, or reclassify the component as Direct-tier with
extra scrutiny).

The target language is established during `/define` and recorded in `docs/PRD.md`. It
applies to all components — Prove-tier and Direct-tier alike — so the whole project
uses a single language.

---

## Direct-tier: LLM Generation Tiers

Direct-tier components are LLM-generated from PRD requirements. The tier system below
describes the quality of that generation.

### Tier 1 — Full Support

- Idiomatic output in the target language's style
- Complete mapping of all PRD constructs to language equivalents
- Tests generated using the language's standard testing framework

**Languages:** Python, TypeScript, JavaScript, Rust, Go, Java, C, C++

**Python** has explicit support for data science and ML workloads: numpy/pandas-compatible
type hints, `dataclasses` for structured types.

### Tier 2 — Standard Support

- Spec-to-code mapping for all PRD constructs
- Best-effort idiomatic output (some constructs may be non-idiomatic)
- Tests generated; may require minor manual adjustment

**Languages:** C#, Kotlin, Swift, Scala, Ruby

### Tier 3 — Basic Support

- Direct structural translation
- Minimal idiomatic adaptation
- All non-obvious constructs flagged for manual review in the diff

Any language not explicitly assigned to Tier 1 or Tier 2 falls into Tier 3,
**except Zig, which is not supported at any tier**.

---

## Requesting a Language Promotion

If your language is Tier 3 and the output is poor, open an issue describing the specific
PRD constructs that didn't translate well. Tier promotions are considered when there is a
concrete spec-to-idiom mapping to implement.
