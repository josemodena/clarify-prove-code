# Workflow Deep Dive

## Overview

```
Task description
      │
      ▼
  ┌─────────┐
  │ /clarify │  Claude Code domain analysis
  └─────────┘
      │  SPEC.md
      ▼
  ┌─────────┐
  │  /prove  │  Dafny formal verification
  └─────────┘
      │  proof/*.dfy  PROOF.md
      ▼
  ┌─────────┐
  │  /code   │  Implementation (auto-merge: OFF)
  └─────────┘
      │  source files + tests  (diff for review)
      ▼
   Human review & merge
```

## Phase 1: Clarify

### What Claude does

Claude Code performs a domain analysis of the problem. This is not just
requirement gathering — it's a structured effort to identify properties that
can later be expressed in first-order logic for the Prove phase.

The analysis covers:
- **Entities**: types, their fields, valid value ranges
- **Invariants**: properties that must hold at all times
- **Operations**: what changes state and how
- **Pre/postconditions**: contracts on each operation
- **Edge cases**: boundary conditions and failure modes

### Output: SPEC.md

`SPEC.md` is the structured output of the Clarify phase. It is the contract
between the Clarify and Prove phases. If a property is not in `SPEC.md`,
it will not be proved.

### When to iterate

Re-run `/clarify` if:
- The spec has gaps (missing edge cases, underspecified error behaviour)
- Dafny cannot express something in `SPEC.md` (usually means the spec is
  too informal; go back and make it more precise)

---

## Phase 2: Prove

### What Claude does

Claude translates `SPEC.md` into Dafny, runs the verifier, and iterates
until all goals are discharged.

The Dafny files live in `proof/`:

```
proof/
├── types.dfy        # Datatypes and type aliases
├── invariants.dfy   # Predicate definitions
├── operations.dfy   # Methods with requires/ensures
└── lemmas.dfy       # Supporting lemmas (added as needed)
```

### Running the verifier manually

```bash
dafny verify proof/*.dfy
```

A clean run shows no errors. Any remaining `assume` statements will be
documented in `PROOF.md` as unverified assumptions.

### Output: PROOF.md

`PROOF.md` records:
- Which properties were formally proved
- The exact `dafny verify` command and Dafny version
- Unverified assumptions and why they couldn't be proved
- Known limitations (e.g. integer overflow not modelled, I/O excluded)

### When to iterate

Re-run `/prove` if:
- `SPEC.md` was updated after an initial proof
- A new requirement was discovered during the Code phase

---

## Phase 3: Code

### What Claude does

Claude reads `PROOF.md` and `proof/*.dfy`, selects the target language,
and generates an implementation where each function traces back to a
verified Dafny method.

### Auto-merge is OFF

Claude will **never** commit or merge changes from the Code phase without
explicit human approval. The output is always a diff presented for review.

This is a deliberate safety control: the proof covers the spec, but
the implementation may still have bugs that require human eyes.

### Traceability

Each generated function includes a comment linking it to its Dafny source:

```python
def transfer(account: Account, amount: int) -> Account:
    # Implements: proof/operations.dfy::Transfer
    # Requires: amount > 0 and account.balance >= amount
    # Ensures: result.balance == account.balance - amount
    ...
```

### What is not generated

Ghost code from Dafny (variables and functions annotated `ghost`) exists
only for specification purposes and is not translated to the implementation.
Where a ghost variable captures an important semantic concept, a comment
is left in the implementation noting what it represents.

---

## Skipping Phases

You can run phases independently if you already have inputs:

- If you have an existing spec, start at `/prove` and point Claude at it.
- If you have an existing proof, start at `/code`.

Do not skip the Prove phase when working on safety-critical or
correctness-sensitive code — that is the whole point of this workflow.
