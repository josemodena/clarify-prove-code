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

**clarify-prove-code** inserts a mathematically verified layer between your English intent and the compiled output:

1. **/clarify** — The agent performs domain analysis, interrogates your idea until it is fully unambiguous. Output: a human-approved PRD.
2. **/prove** — The agent translates the PRD into [Dafny](https://github.com/dafny-lang/dafny) and runs the formal verifier. Output: a machine-verified spec.
3. **/code** — The agent transpiles the verified spec into production code in your target language. Output: implementation + traceability summary. **Auto-merge is off** — you review and approve the diff before anything is committed.

No code is written without a proof. No proof is accepted without a passing verifier. No verifier runs without human-approved requirements.

---

## Language Support

| Tier | Languages | Support level |
|------|-----------|---------------|
| 1 | Python, TypeScript, JavaScript, Rust, Go, Java, C, C++ | Full: idiomatic output + complete spec mapping |
| 2 | C#, Kotlin, Swift, Scala, Ruby | Standard: spec mapping, best-effort idioms |
| 3 | All others (except Zig) | Basic: direct structural translation |

**Python is Tier 1** with explicit support for data science and ML workloads (numpy/pandas-compatible type hints, `dataclasses` for Dafny types).

**Zig is not supported.**

For the full language mapping and rationale, see [docs/language-support.md](docs/language-support.md).

---

## Quick Start

### Option A — Plugin installation (global, recommended)

Install once; `/clarify`, `/prove`, and `/code` become available in every Claude Code session.

```sh
# 1. Register the GitHub repo as a plugin source
claude plugin marketplace add https://github.com/josemodena/clarify-prove-code

# 2. Install the plugin
claude plugin install clarify-prove-code

# 3. Install Dafny
bash scripts/install-dafny.sh

# 4. Start any session — the skills are available immediately
claude
```

To remove the plugin later:

```sh
claude plugin uninstall clarify-prove-code
```

### Option B — Session-only (no permanent install)

Load the plugin for a single Claude Code session without installing it globally:

```sh
git clone https://github.com/josemodena/clarify-prove-code ~/clarify-prove-code
bash ~/clarify-prove-code/scripts/install-dafny.sh
claude --plugin-dir ~/clarify-prove-code
```

### Option C — Project-level installation (via install script)

Copies commands and `CLAUDE.md` into a specific project directory so the skills work in that project only:

```sh
git clone https://github.com/josemodena/clarify-prove-code ~/clarify-prove-code
cd my-project
bash ~/clarify-prove-code/scripts/install.sh
```

The installer:
- Copies `.claude/commands/` and `CLAUDE.md` into your project
- Installs Dafny (and .NET if needed) automatically
- Verifies all tools are present

#### Install script options

```sh
# Skip Dafny if already installed
bash scripts/install.sh --skip-dafny

# Install into a specific directory
bash scripts/install.sh --target=/path/to/project
```

### Install Dafny manually (if preferred)

```sh
# Linux / macOS — auto-detects best method (Homebrew, .NET tool, or binary)
bash scripts/install-dafny.sh

# Override install method
INSTALL_METHOD=dotnet bash scripts/install-dafny.sh
INSTALL_METHOD=binary DAFNY_VERSION=4.4.0 bash scripts/install-dafny.sh
```

### Verify the environment

```sh
bash scripts/verify-deps.sh
```

### Start a session

```sh
# In your application project folder:
claude

# Then:
/clarify I want to build a thread-safe rate limiter that allows 100 requests per user per minute.
```

The agent will interrogate your idea, write a PRD, wait for your approval, write and verify the formal spec, and finally emit production code in your chosen language — with a diff for your review before anything is merged.

---

## Repository Structure

```
clarify-prove-code/
├── package.json                 ← Plugin manifest (name, version)
├── CLAUDE.md                    ← Master rules for Claude Code
├── skills/                      ← Plugin skills (global installation)
│   ├── clarify/
│   │   └── SKILL.md             ← /clarify skill definition
│   ├── prove/
│   │   └── SKILL.md             ← /prove skill definition
│   └── code/
│       └── SKILL.md             ← /code skill definition
├── .claude/
│   ├── settings.json            ← Plugin config (language tiers, auto-merge flag)
│   └── commands/
│       ├── clarify.md           ← /clarify (project-level installation)
│       ├── prove.md             ← /prove (project-level installation)
│       └── code.md              ← /code (project-level installation)
├── scripts/
│   ├── install.sh               ← Project-level installer (copies commands + CLAUDE.md)
│   ├── install-dafny.sh         ← Dafny installer (Linux / macOS)
│   └── verify-deps.sh           ← Dependency checker
├── docs/
│   ├── METHODOLOGY.md           ← Full rationale for the methodology
│   ├── getting-started.md       ← Step-by-step setup guide
│   ├── language-support.md      ← Language tier details and mappings
│   └── workflow.md              ← Deep dive into the three phases
└── templates/
    ├── PRD_TEMPLATE.md          ← Template for /clarify output
    └── SPEC_TEMPLATE.md         ← Guide for Dafny spec structure
```

When using this kit with an application project, the agent writes its outputs there:

```
your-app/
├── docs/
│   ├── PRD.md                   ← Output of /clarify
│   ├── PROOF.md                 ← Output of /prove (summary)
│   └── TRACE.md                 ← Output of /code (traceability)
├── logic/
│   └── *.dfy                    ← Output of /prove (verified Dafny)
└── src/
    └── *                        ← Output of /code (production code, diff for review)
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
    ↓ /code (isomorphic transpilation, no auto-merge)
src/
    ↓
docs/TRACE.md (audit trail)
```

If a bug is found, the chain tells you exactly where it entered.

---

## When to Use This

**Use it for your entire application.** The methodology handles scope for you.

During `/clarify`, the agent analyses every component and proposes a **Verification Scope**:
which components need formal proof (payment logic, permissions, data integrity) and which
can go directly to code (UI, glue, scripts). You review and approve the triage as part of
the PRD sign-off — one step, not two.

The result: full PRD coverage across the codebase, with Dafny verification targeted at
the components where a bug would be catastrophic, and direct code generation everywhere else.

---

## Further Reading

- [docs/METHODOLOGY.md](docs/METHODOLOGY.md) — The full rationale
- [docs/getting-started.md](docs/getting-started.md) — Setup walkthrough
- [docs/language-support.md](docs/language-support.md) — Language tier details
- [docs/workflow.md](docs/workflow.md) — Phase-by-phase deep dive
- [Dafny documentation](https://dafny.org/)
- [Verus (formal verification for Rust)](https://github.com/verus-lang/verus)
