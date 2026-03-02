# Getting Started

## Prerequisites

- [Claude Code](https://docs.anthropic.com/claude-code) installed and configured
- A POSIX shell (bash or zsh) for running the install scripts
- Internet access for the initial Dafny download

## Quick Install

```bash
# 1. Clone the plugin
git clone https://github.com/josemodena/clarify-prove-code ~/clarify-prove-code

# 2. Go to the project where you want to use it
cd my-project

# 3. Install
bash ~/clarify-prove-code/scripts/install.sh
```

That's it. The installer handles Dafny and .NET automatically.

## Manual Dafny Installation

If you prefer to install Dafny separately, or if the automatic install fails:

### Via .NET global tool (recommended on all platforms)

```bash
# Install .NET SDK first (if not present)
curl -sSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel 8.0

# Then install Dafny
dotnet tool install --global Dafny
```

### Via Homebrew (macOS)

```bash
brew install dafny
```

### Via binary download (Linux / macOS)

Download the appropriate release from
[https://github.com/dafny-lang/dafny/releases](https://github.com/dafny-lang/dafny/releases)
and add it to your `PATH`.

Once Dafny is installed, verify with:

```bash
dafny --version
```

Then install the plugin without re-running the Dafny installer:

```bash
bash ~/clarify-prove-code/scripts/install.sh --skip-dafny
```

## Verify Everything Is Ready

```bash
bash ~/clarify-prove-code/scripts/verify-deps.sh
```

Expected output:

```
Checking required tools...

  ✓ dafny   — Dafny 4.6.0

  ? dotnet  — not found (only required if using INSTALL_METHOD=dotnet)

Checking optional language runtimes (Tier 1)...

  ✓ python3 — Python 3.12.0
  ...

All required tools are present.
```

## First Workflow

Open Claude Code in your project directory and try:

```
/clarify write a function that merges two sorted lists into a sorted list
```

Claude will analyse the domain, ask any needed questions, and produce `docs/PRD.md`
including a Verification Scope in Section 9.

See [Workflow Deep Dive](workflow.md) for what happens next.
