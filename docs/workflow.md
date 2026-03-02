# Workflow Deep Dive

## Overview

```
Task description
      │
      ▼
  ┌─────────┐
  │ /define  │  Domain analysis + Target Language + Verification Scope triage
  └─────────┘
      │  docs/PRD.md  (requirements + Target Language + Section 9: Verification Scope)
      ▼
  ┌─────────┐
  │  /prove  │  Dafny formal verification (Prove-tier components only)
  └─────────┘
      │  logic/*.dfy  docs/PROOF.md
      ▼
  ┌─────────┐
  │  /code   │  Implementation (auto-merge: OFF)
  └─────────┘
      │  src/  docs/TRACE.md  (diff for review)
      ▼
   Human review & merge
```

---

## Phase 1: Define

### What Claude does

Claude Code performs a domain analysis of the problem. This is not just requirement
gathering — it's a structured effort to identify properties that can later be expressed
in first-order logic for the Prove phase.

The analysis covers:
- **Entities**: types, their fields, valid value ranges
- **Invariants**: properties that must hold at all times
- **Operations**: what changes state and how
- **Pre/postconditions**: contracts on each operation
- **Edge cases**: boundary conditions and failure modes

Claude also establishes the **Target Language** early in the dialogue. If any components
are likely to be Prove-tier, the language must be one the Dafny compiler supports
(Python, Go, Java, JavaScript/TypeScript, C#, Rust). This is confirmed before drafting
the PRD, not after.

At the end of the analysis, Claude proposes a **Verification Scope** (Section 9 of the PRD):
a triage table assigning each identified component a tier.

| Tier | When to apply |
|---|---|
| **Prove** | Financial logic, access control, data integrity, state machines with complex transitions, security boundaries, safety-critical behaviour |
| **Direct** | UI components, API glue, configuration loading, logging, scripts, prototypes |

### Output: docs/PRD.md

`docs/PRD.md` is the structured output of the Define phase. It is the contract between
Define and all subsequent phases. If a property is not in `docs/PRD.md`, it will not be
proved or generated. The Target Language field determines which compiler path is used
in `/code`. Section 9 (Verification Scope) determines which path each component takes
through the rest of the pipeline.

### When to iterate

Re-run `/define` if:
- The spec has gaps (missing edge cases, underspecified error behaviour)
- Dafny cannot express something in the PRD (go back and make it more precise)
- The human wants to change a triage decision in Section 9
- The target language needs to change (e.g. a Prove-tier component was added and the
  current language is not a Dafny compile target)

---

## Phase 2: Prove

### What Claude does

Claude reads Section 9 of `docs/PRD.md` and collects every component marked **Prove**.
It translates each one into Dafny, runs the verifier, and iterates until all goals
are discharged.

**Direct-tier components skip this phase entirely** — they proceed straight to `/code`.

If no components are marked Prove, this phase is skipped.

The Dafny files live in `logic/`:

```
logic/
├── <component-a>.dfy   # Prove-tier component A
├── <component-b>.dfy   # Prove-tier component B
└── ...
```

### Running the verifier manually

```bash
dafny verify logic/*.dfy
```

A clean run shows no errors. Any remaining `assume` statements will be documented
in `docs/PROOF.md` as unverified assumptions.

### Output: docs/PROOF.md

`docs/PROOF.md` records:
- Which Prove-tier components were formally verified
- The exact `dafny verify` command and Dafny version
- Unverified assumptions and why they couldn't be proved
- Known limitations (e.g. integer overflow not modelled, I/O excluded)

### When to iterate

Re-run `/prove` if:
- `docs/PRD.md` was updated after an initial proof
- A new requirement was discovered during the Code phase
- A triage decision changed a Direct component to Prove

---

## Phase 3: Code

### What Claude does

Claude reads `docs/PRD.md` Section 9 and the Target Language field, then generates
production code using two paths:

**Prove-tier components:**
Claude runs the Dafny compiler against the verified spec:
```bash
dafny translate <target> logic/<component>.dfy --output src/
```
The compiler output is isomorphic to the spec by construction — no LLM translation,
no manual code writing. The generated file gets a header comment marking it as
compiler output. No business logic can be introduced.

**Direct-tier components:**
Claude reads the relevant PRD sections (operations, failure modes, edge cases) and
generates code directly using the target language. Each function traces back to a PRD
requirement. Every failure mode is an explicit return type, not an exception or a panic.

### Auto-merge is OFF

Claude will **never** commit or merge changes from the Code phase without explicit human
approval. The output is always a diff presented for review.

This is a deliberate safety control: the Dafny proof covers the spec, and the compiler
guarantees the translation — but the final diff still requires human eyes before merging.

### Traceability

`docs/TRACE.md` maps every `src/` function to both its source and its PRD requirement:

```
| src/ function           | Source                        | PRD requirement        |
|-------------------------|-------------------------------|------------------------|
| payment.transfer()      | dafny:logic/payment.dfy       | PRD §4.1               |
| dashboard.render()      | PRD direct                    | PRD §4.3               |
| auth.checkPermission()  | dafny:logic/auth.dfy          | PRD §4.2               |
```

Prove-tier functions reference `dafny:logic/<component>.dfy`. Direct-tier functions
reference the PRD section directly.

### What is not generated

Ghost code from Dafny (variables and functions annotated `ghost`) exists only for
specification purposes and is not emitted by the compiler. Where a ghost variable
captures an important semantic concept, a comment is left in the implementation.

---

## Skipping Phases

- If no components are marked Prove in Section 9, the `/prove` phase is skipped entirely.
  Run `/define` then go directly to `/code`.
- If you have an existing approved PRD and verified Dafny specs, start at `/code`.

Do not skip `/define`. The PRD (including the Target Language field and Verification Scope)
is a required input for both `/prove` and `/code`.
