# Workflow Deep Dive

## Overview

```
Task description
      │
      ▼
  ┌─────────┐
  │ /clarify │  Domain analysis + Verification Scope triage
  └─────────┘
      │  docs/PRD.md  (requirements + Section 9: Verification Scope)
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

## Phase 1: Clarify

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

At the end of the analysis, Claude proposes a **Verification Scope** (Section 9 of the PRD):
a triage table assigning each identified component a tier.

| Tier | When to apply |
|---|---|
| **Prove** | Financial logic, access control, data integrity, state machines with complex transitions, security boundaries, safety-critical behaviour |
| **Direct** | UI components, API glue, configuration loading, logging, scripts, prototypes |

### Output: docs/PRD.md

`docs/PRD.md` is the structured output of the Clarify phase. It is the contract between
Clarify and all subsequent phases. If a property is not in `docs/PRD.md`, it will not be
proved or generated. Section 9 (Verification Scope) determines which path each component
takes through the rest of the pipeline.

### When to iterate

Re-run `/clarify` if:
- The spec has gaps (missing edge cases, underspecified error behaviour)
- Dafny cannot express something in the PRD (go back and make it more precise)
- The human wants to change a triage decision in Section 9

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

Claude reads `docs/PRD.md` Section 9 and generates production code using two paths:

**Prove-tier components:**
Claude reads `logic/<component>.dfy`, confirms it passes `dafny verify`, and transpiles
it isomorphically into the target language. No new business logic is introduced. Each
function traces back to a verified Dafny method.

**Direct-tier components:**
Claude reads the relevant PRD sections (operations, failure modes, edge cases) and
generates code directly. Each function traces back to a PRD requirement. Every failure
mode is an explicit return type, not an exception or a panic.

### Auto-merge is OFF

Claude will **never** commit or merge changes from the Code phase without explicit human
approval. The output is always a diff presented for review.

This is a deliberate safety control: the proof covers the spec, but the implementation
may still have bugs that require human eyes.

### Traceability

`docs/TRACE.md` maps every `src/` function to both its proof source and its PRD requirement:

```
| src/ function           | Proof source                      | PRD requirement        |
|-------------------------|-----------------------------------|------------------------|
| payment.transfer()      | logic/payment.dfy::Transfer       | PRD §4.1               |
| dashboard.render()      | PRD direct                        | PRD §4.3               |
| auth.checkPermission()  | logic/auth.dfy::CheckPerm         | PRD §4.2               |
```

Functions from Prove-tier components reference their Dafny source. Functions from
Direct-tier components reference the PRD section directly.

### What is not generated

Ghost code from Dafny (variables and functions annotated `ghost`) exists only for
specification purposes and is not translated. Where a ghost variable captures an
important semantic concept, a comment is left in the implementation.

---

## Skipping Phases

- If no components are marked Prove in Section 9, the `/prove` phase is skipped entirely.
  Run `/clarify` then go directly to `/code`.
- If you have an existing approved PRD and verified Dafny specs, start at `/code`.

Do not skip `/clarify`. The PRD and Verification Scope are required inputs for both
`/prove` and `/code`.
