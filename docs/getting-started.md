# Getting Started

## Prerequisites

- [Claude Code](https://docs.anthropic.com/claude-code) installed and configured
- A POSIX shell (bash or zsh) for running the install scripts
- Internet access for the initial Dafny download

## Installation Options

There are three ways to install vulcan depending on how broadly you want the
skills available.

### Option A — Global plugin (recommended)

Installs the skills into Claude Code globally so `/define`, `/prove`, and `/code` work in
every session without any per-project setup.

```bash
# 1. Register the GitHub repo as a plugin source
claude plugin marketplace add https://github.com/josemodena/vulcan

# 2. Install the plugin
claude plugin install vulcan

# 3. Install Dafny
bash scripts/install-dafny.sh
```

To verify the plugin is registered:

```bash
claude plugin list
```

To remove it later:

```bash
claude plugin uninstall vulcan
```

### Option B — Session-only plugin

Load the plugin for a single Claude Code session. Nothing is permanently installed.

```bash
# 1. Clone the repo
git clone https://github.com/josemodena/vulcan ~/vulcan

# 2. Install Dafny
bash ~/vulcan/scripts/install-dafny.sh

# 3. Start Claude Code with the plugin loaded
claude --plugin-dir ~/vulcan
```

### Option C — Project-level installation

Copies the commands and `CLAUDE.md` into a specific project. The skills are available only
in that project directory.

```bash
# 1. Clone the plugin
git clone https://github.com/josemodena/vulcan ~/vulcan

# 2. Go to the project where you want to use it
cd my-project

# 3. Install
bash ~/vulcan/scripts/install.sh
```

The installer handles Dafny and .NET automatically.

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
bash ~/vulcan/scripts/install.sh --skip-dafny
```

## Verify Everything Is Ready

```bash
bash ~/vulcan/scripts/verify-deps.sh
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
/define write a function that merges two sorted lists into a sorted list
```

Claude will analyse the domain, ask any needed questions (including target language),
and produce `docs/PRD.md` including a Verification Scope in Section 9.

See [Workflow Deep Dive](workflow.md) for what happens next.
