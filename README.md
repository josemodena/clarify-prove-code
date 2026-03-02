# clarify-prove-code

A methodology and Claude Code orchestration kit for building high-assurance software in the agent era.

```
/clarify  →  /prove  →  /code
```

---

## The Problem

English is ambiguous. High-level languages are permissive. When an AI agent writes code directly from a natural language prompt, there is no formal checkpoint between what you *meant* and what the machine *executes*.

This gap — the Ambiguity Gap — is where bugs, security flaws, and hallucinated logic live.

## The Solution

**clarify-prove-code** inserts a mathematically verified layer between your English intent and the compiled binary:

1. **/clarify** — The agent interrogates your idea until it is fully unambiguous. Output: a human-approved PRD.
2. **/prove** — The agent translates the PRD into [Dafny](https://github.com/dafny-lang/dafny) and runs the formal verifier. Output: a machine-verified spec.
3. **/code** — The agent transpiles the verified spec into Rust or Zig. Output: production code with a full traceability summary.

No code is written without a proof. No proof is accepted without a passing verifier. No verifier runs without human-approved requirements.

---

## Why Rust and Zig (not Python)?

When a human writes code, readability is the priority. When an agent writes code, verifiability is the priority. Rust and Zig are:

- **Explicit** — no hidden allocations, no hidden control flow
- **Compile-time safe** — errors surface before runtime
- **Auditable** — a second agent or a human reviewer can verify what every line does
- **Resource-predictable** — no garbage collector, no runtime surprises

Python remains useful for prototypes and scripts. It is not a suitable target for agent-era production systems where correctness must be proven, not assumed.

For the full rationale, see [docs/METHODOLOGY.md](docs/METHODOLOGY.md).

---

## Quick Start

### 1. Install dependencies

```sh
# Dafny (formal verifier)
# See https://github.com/dafny-lang/dafny/releases

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Zig
# See https://ziglang.org/download/
```

### 2. Clone this repo

```sh
git clone https://github.com/your-org/clarify-prove-code
cd clarify-prove-code
```

### 3. Link to your project

In your application project folder:

```sh
claude --add-dir /path/to/clarify-prove-code
```

### 4. Start a session

```sh
# In your application project folder:
claude

# Then:
/clarify I want to build a thread-safe rate limiter that allows 100 requests per user per minute.
```

The agent will interrogate your idea, write a PRD, wait for your approval, write and verify the formal spec, and finally emit production Rust or Zig.

---

## Repository Structure

```
clarify-prove-code/
├── CLAUDE.md                    ← Master rules for Claude Code
├── .claude/
│   └── skills/
│       ├── clarify.md           ← /clarify skill definition
│       ├── prove.md             ← /prove skill definition
│       └── code.md              ← /code skill definition
├── docs/
│   └── METHODOLOGY.md           ← Full explanation of the methodology
└── templates/
    ├── PRD_TEMPLATE.md          ← Template for /clarify output
    └── SPEC_TEMPLATE.md         ← Guide for Dafny spec structure
```

When using this kit with an application project, the agent writes its outputs there:

```
your-app/
├── docs/
│   ├── PRD.md                   ← Output of /clarify
│   └── TRACE.md                 ← Output of /code (traceability)
├── logic/
│   └── *.dfy                    ← Output of /prove (verified Dafny)
└── src/
    └── *.rs / *.zig             ← Output of /code (production code)
```

---

## The Traceability Chain

Every artifact traces back to the one before it:

```
English idea
    ↓ /clarify (human-approved)
docs/PRD.md
    ↓ /prove (machine-verified)
logic/*.dfy
    ↓ /code (isomorphic transpilation)
src/
    ↓
docs/TRACE.md (audit trail)
```

If a bug is found, the chain tells you exactly where it entered.

---

## When to Use This

**Use it for** the 20% of your codebase where bugs are catastrophic:
- Payment and financial logic
- Permission and access control
- Data integrity guarantees
- Safety-critical or embedded systems

**Skip it for** the other 80%:
- UI components
- Scripts and automation
- API glue code
- Prototypes

---

## Further Reading

- [docs/METHODOLOGY.md](docs/METHODOLOGY.md) — The full rationale
- [Dafny documentation](https://dafny.org/)
- [Verus (formal verification for Rust)](https://github.com/verus-lang/verus)
- [Zig language](https://ziglang.org/)
- [Rust language](https://www.rust-lang.org/)
