# The clarify-prove-code Methodology

## The Problem

For decades, high-level languages (Python, JavaScript, Java) were justified by a single argument: humans need to read and write the code. Verbosity and complexity were the enemy. Abstractions — garbage collectors, dynamic typing, hidden runtimes — were the solution.

That justification is now weakening.

When an AI agent is the one writing code, the "human cognitive load" argument collapses. The agent does not get tired reading verbose syntax. It does not find strict type systems frustrating. What the agent needs is not a language that is easy for humans to skim — it needs a language that is hard to get wrong.

At the same time, natural language (English) is increasingly the interface between humans and agents. But English is ambiguous. "Build a cache" can mean ten different things. If an agent acts directly on an ambiguous prompt, it produces plausible-looking code that satisfies none of the invariants the human had in mind.

**This is the Ambiguity Gap:** the space between what a human means and what an agent produces.

---

## The Insight

The jump from low-level languages (C, Assembly) to high-level ones (Python, Ruby) was motivated by reducing human cognitive load. Now that agents are managing the syntax, that motivation is gone.

What an agent-era language needs instead:

- Forces the agent to be **specific** — no implicit behaviour
- Detects errors at **compile time** — not at runtime in production
- Makes code **easy to audit** — by a second agent or a human

Under these criteria, explicit, strongly typed languages outperform permissive ones. Not because they are better for humans, but because they are better for agents.

---

## The Three-Phase Pipeline

**clarify-prove-code** bridges the Ambiguity Gap with a mandatory three-phase pipeline.

### Phase 1: Clarify

**Input:** a human idea, stated in English.
**Output:** `docs/PRD.md` — a structured specification approved by the human, including a Verification Scope.

The agent does not write code. It interrogates. It asks about invariants, edge cases, failure modes, and security boundaries until the human's intent is fully unambiguous. The result is a document the human has read and approved — not an assumption the agent made.

At the end of this phase, the agent proposes a **Verification Scope** (Section 9 of the PRD): a triage table assigning each component a tier.

- **Prove** — must go through formal Dafny verification before any code is written. Applied to: payment logic, access control, data integrity, state machines with complex transitions, security boundaries, safety-critical behaviour.
- **Direct** — goes straight from PRD to code generation. Applied to: UI, API glue, configuration, logging, scripts, prototypes.

The human reviews and approves both the requirements and the triage in a single sign-off.

**Why this phase exists:** Errors found here cost 60 seconds. Errors found in production cost far more. The Verification Scope ensures formal verification is targeted precisely where it adds value, so the pipeline can cover the entire application without unnecessary overhead.

### Phase 2: Prove

**Input:** `docs/PRD.md` Section 9 (Verification Scope)
**Output:** `logic/*.dfy` — Dafny specifications, mathematically verified.

The agent reads the Verification Scope and processes only the components marked **Prove**. Direct-tier components skip this phase entirely.

For each Prove component, the agent translates the approved requirements into formal logic using [Dafny](https://dafny.org/), a verification-aware language. It then runs the Dafny verifier, which uses an SMT solver (Z3) to mathematically prove that the logic satisfies every stated invariant.

If the proof fails, the agent explains the counter-example in plain English and fixes the spec. No code is written until the verifier passes with zero errors.

If no components are marked Prove, this phase is skipped.

**Why this phase exists:** Natural language is ambiguous. Python is permissive. Neither can be used as a formal source of truth. Dafny can. A verified `.dfy` file is not a test that passed — it is a mathematical proof that the logic is correct for all possible inputs within its stated preconditions.

### Phase 3: Code

**Input:** `docs/PRD.md` (Verification Scope) + `logic/*.dfy` (for Prove-tier components)
**Output:** `src/` — production code in the target language, with a traceability summary.

The agent generates code using two paths:

- **Prove-tier components:** Transpile isomorphically from the verified Dafny spec. No new business logic may be introduced. Every function maps to a verified Dafny method.
- **Direct-tier components:** Generate from PRD requirements directly. Every function maps to a PRD operation. Every failure mode maps to an explicit return type.

The agent produces a mandatory `docs/TRACE.md` mapping each `src/` function to its source: either a `logic/*.dfy` method or a PRD section directly.

**Auto-merge is off.** The human reviews and approves the diff before anything is committed.

---

## The Traceability Chain

Every artifact traces back to the one before it:

```
English idea
    ↓ /clarify (human-approved, including Verification Scope)
docs/PRD.md
    ↓ /prove (machine-verified — Prove-tier components only)
logic/*.dfy
    ↓ /code (two paths: isomorphic from Dafny, or direct from PRD)
src/
    ↓
docs/TRACE.md (proof source + PRD requirement per function)
```

If a bug is found, the chain tells you exactly where it entered:

- Does `src/` match its source (Dafny spec or PRD)? → Code translation error
- Does `logic/*.dfy` satisfy all invariants? → The verifier would have caught this
- Does `docs/PRD.md` correctly capture the intent? → Requirements gap — return to `/clarify`

---

## The Role of a Second Agent

The methodology is designed for multi-agent review. Once `/code` is complete:

- A **Reviewer Agent** reads `docs/TRACE.md` and verifies that every PRD requirement maps to either a verified Dafny invariant or a PRD-direct function.
- A **Differential Testing Agent** can run the Dafny model and the compiled binary against identical inputs and verify equivalence for Prove-tier components.
- Neither agent needs to understand the English intent — they only verify mechanical correspondence between layers.

---

## What This Is Not

- It is not a silver bullet. The PRD is only as good as the human's answers during `/clarify`. Garbage in, garbage out — the formal proofs will be mathematically correct but semantically wrong.
- It is not fully automated. Human sign-off after `/clarify` is mandatory. The human is the architect; the agent is the engineer.

---

## Tooling Requirements

| Tool | Purpose | License |
|---|---|---|
| [Dafny](https://github.com/dafny-lang/dafny) | Formal specification and verification | MIT |
| [Claude Code](https://claude.ai/code) | Agent executing the pipeline | Commercial |

Install Dafny: `bash scripts/install-dafny.sh`
