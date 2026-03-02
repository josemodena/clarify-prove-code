# The clarify-prove-code Methodology

## The Problem

For decades, high-level languages (Python, JavaScript, Java) were justified by a single argument: humans need to read and write the code. Verbosity and complexity were the enemy. Abstractions — garbage collectors, dynamic typing, hidden runtimes — were the solution.

That justification is now weakening.

When an AI agent is the one writing code, the "human cognitive load" argument collapses. The agent does not get tired reading verbose Zig allocator syntax. It does not find Rust's borrow checker frustrating. What the agent needs is not a language that is easy for humans to skim — it needs a language that is hard to get wrong.

At the same time, natural language (English) is increasingly the interface between humans and agents. But English is ambiguous. "Build a cache" can mean ten different things. If an agent acts directly on an ambiguous prompt, it produces plausible-looking code that satisfies none of the invariants the human had in mind.

**This is the Ambiguity Gap:** the space between what a human means and what an agent produces.

---

## The Insight

The jump from low-level languages (C, Assembly) to high-level ones (Python, Ruby) was motivated by reducing human cognitive load. Now that agents are managing the syntax, that motivation is gone.

What an agent-era language needs instead:

- Forces the agent to be **specific** — no implicit behavior
- Detects errors at **compile time** — not at runtime in production
- Maximises **performance** — no hidden garbage collectors or runtimes
- Consumes **few resources** — predictable memory, binary size
- Makes code **easy to audit** — by a second agent or a human

Under these criteria, Rust and Zig outperform Python and JavaScript. Not because they are better for humans, but because they are better for agents: explicit, verifiable, and transparent.

---

## The Three-Phase Pipeline

**clarify-prove-code** bridges the Ambiguity Gap with a mandatory three-phase pipeline.

### Phase 1: Clarify

**Input:** a human idea, stated in English.
**Output:** `docs/PRD.md` — a structured specification approved by the human.

The agent does not write code. It interrogates. It asks about invariants, edge cases, failure modes, and security boundaries until the human's intent is fully unambiguous. The result is a document the human has read and approved — not an assumption the agent made.

**Why this phase exists:** If you send a raw English prompt to a code generator, you get code that is plausible but possibly wrong. The PRD forces the human to think through the edge cases before a single line of logic is written. Errors found here cost 60 seconds. Errors found in production cost far more.

### Phase 2: Prove

**Input:** `docs/PRD.md`
**Output:** `logic/*.dfy` — Dafny specifications, mathematically verified.

The agent translates the approved requirements into formal logic using [Dafny](https://dafny.org/), a verification-aware language. It then runs the Dafny verifier, which uses an SMT solver (Z3) to mathematically prove that the logic satisfies every stated invariant.

If the proof fails, the agent explains the counter-example in plain English and fixes the spec. No code is written until the verifier passes with zero errors.

**Why this phase exists:** Natural language is ambiguous. Python is permissive. Neither can be used as a formal "source of truth." Dafny can. A verified `.dfy` file is not a test that passed — it is a mathematical proof that the logic is correct for all possible inputs within its stated preconditions.

**Why not Python as the intermediate step?** Python can disambiguate intent, but it introduces a new problem: when the agent translates Python to Rust or Zig, it must interpret Python's dynamic semantics in terms of a static, low-level type system. This translation is a hallucination surface. Dafny is not a runtime language — it is a specification language. It has no runtime to misinterpret.

### Phase 3: Code

**Input:** `logic/*.dfy` (verified)
**Output:** `src/` — production Rust or Zig, with a traceability summary.

The agent transpiles the proven Dafny logic into production code. No new business logic is introduced at this phase — the code must be isomorphic to the spec. Every function in `src/` maps to a verified method in `logic/`.

The agent produces a mandatory `docs/TRACE.md` that maps each production function back to its Dafny invariant and its original PRD requirement.

**Why Rust or Zig?** Because the agent is writing the code, human readability is secondary. What matters is: explicit memory, compile-time error detection, no hidden runtimes, and auditability. Both Rust and Zig satisfy all four. Rust's borrow checker provides additional memory safety guarantees. Zig's allocator pattern provides maximum transparency and control.

---

## The Traceability Chain

Every artifact in the pipeline traces to the one before it:

```
English idea
    ↓ /clarify
docs/PRD.md  (human-approved)
    ↓ /prove
logic/*.dfy  (machine-verified)
    ↓ /code
src/         (production binary)
    ↓
docs/TRACE.md (audit trail)
```

If a bug is found in production, the chain tells you exactly where the failure occurred:

- Does `src/` match `logic/*.dfy`? → Code translation error
- Does `logic/*.dfy` satisfy all invariants? → The verifier would have caught this
- Does `docs/PRD.md` correctly capture the intent? → Requirements gap — return to `/clarify`

---

## The Role of a Second Agent

The methodology is designed for multi-agent review. Once `/code` is complete:

- A **Reviewer Agent** reads `docs/TRACE.md` and verifies that every PRD requirement maps to a verified Dafny invariant and a production function.
- A **Differential Testing Agent** can run the Dafny model and the compiled binary against identical inputs and verify bit-for-bit equivalence.
- Neither agent needs to understand the English intent — they only verify mechanical correspondence between layers.

---

## What This Is Not

- It is not a silver bullet. The PRD is only as good as the human's answers during `/clarify`. Garbage in, garbage out — the formal proofs will be mathematically correct but semantically wrong.
- It is not suitable for every project. UI code, scripts, and prototypes do not benefit from this overhead. Target it at the 20% of your codebase where bugs are catastrophic: payment logic, permissions, data integrity, safety-critical systems.
- It is not fully automated. Human sign-off after `/clarify` is mandatory. The human is the architect; the agent is the engineer.

---

## Tooling Requirements

| Tool | Purpose | License |
|---|---|---|
| [Dafny](https://github.com/dafny-lang/dafny) | Formal specification and verification | MIT |
| [Verus](https://github.com/verus-lang/verus) | Formal verification inside Rust | MIT/Apache 2.0 |
| [Claude Code](https://claude.ai/code) | Agent executing the pipeline | Commercial |
| Rust toolchain | Production code target | MIT/Apache 2.0 |
| Zig toolchain | Production code target | MIT |

Install Dafny: https://github.com/dafny-lang/dafny/releases
