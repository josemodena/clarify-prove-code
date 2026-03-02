#!/usr/bin/env bash
# install.sh — Install the clarify-prove-code plugin into a target project
#
# Usage (from project root where you want to install):
#   bash /path/to/clarify-prove-code/scripts/install.sh
#
# What this script does:
#   1. Copies .claude/ commands and settings into the target project
#   2. Copies CLAUDE.md into the target project
#   3. Installs Dafny (unless --skip-dafny is passed)
#   4. Runs verify-deps.sh to confirm the environment is ready

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_DIR="${TARGET_DIR:-$(pwd)}"
SKIP_DAFNY="${SKIP_DAFNY:-false}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${GREEN}[install]${NC} $*"; }
warn()    { echo -e "${YELLOW}[install]${NC} $*"; }
step()    { echo -e "${BLUE}[install]${NC} $*"; }
error()   { echo -e "${RED}[install] ERROR:${NC} $*" >&2; exit 1; }

for arg in "$@"; do
    case "$arg" in
        --skip-dafny) SKIP_DAFNY=true ;;
        --target=*)   TARGET_DIR="${arg#--target=}" ;;
        --help|-h)
            echo "Usage: bash scripts/install.sh [--skip-dafny] [--target=<dir>]"
            echo
            echo "Options:"
            echo "  --skip-dafny     Do not install Dafny (useful in CI or if already installed)"
            echo "  --target=<dir>   Install into <dir> instead of the current directory"
            exit 0
            ;;
        *) warn "Unknown argument: $arg (ignored)" ;;
    esac
done

[[ -d "$TARGET_DIR" ]] || error "Target directory does not exist: $TARGET_DIR"

step "Installing clarify-prove-code plugin into: $TARGET_DIR"
echo

# ── 1. Copy .claude/ directory ───────────────────────────────────────────────
step "Copying .claude/ commands and settings..."

TARGET_CLAUDE="$TARGET_DIR/.claude"
mkdir -p "$TARGET_CLAUDE/commands"

# Merge settings if target already has one
if [[ -f "$TARGET_CLAUDE/settings.json" ]]; then
    warn "Existing .claude/settings.json found. Merging clarify_prove_code key..."
    if command -v python3 &>/dev/null; then
        python3 - <<'EOF'
import json, sys

target = sys.argv[1]
source = sys.argv[2]

with open(target) as f:
    existing = json.load(f)
with open(source) as f:
    plugin = json.load(f)

existing.update(plugin)

with open(target, "w") as f:
    json.dump(existing, f, indent=2)
    f.write("\n")

print("Merged successfully.")
EOF
        python3 - "$TARGET_CLAUDE/settings.json" "$PLUGIN_ROOT/.claude/settings.json"
    else
        warn "python3 not found; overwriting settings.json. Back it up first if needed."
        cp "$PLUGIN_ROOT/.claude/settings.json" "$TARGET_CLAUDE/settings.json"
    fi
else
    cp "$PLUGIN_ROOT/.claude/settings.json" "$TARGET_CLAUDE/settings.json"
fi

# Copy command files (overwrite)
for cmd in clarify prove code; do
    cp "$PLUGIN_ROOT/.claude/commands/${cmd}.md" "$TARGET_CLAUDE/commands/${cmd}.md"
    info "  Installed command: /${cmd}"
done

# ── 2. Copy CLAUDE.md ─────────────────────────────────────────────────────────
step "Installing CLAUDE.md..."
if [[ -f "$TARGET_DIR/CLAUDE.md" ]]; then
    warn "Existing CLAUDE.md found. Appending plugin section..."
    {
        echo
        echo "---"
        echo "<!-- clarify-prove-code plugin -->"
        cat "$PLUGIN_ROOT/CLAUDE.md"
    } >> "$TARGET_DIR/CLAUDE.md"
else
    cp "$PLUGIN_ROOT/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
fi

# ── 3. Install Dafny ──────────────────────────────────────────────────────────
if [[ "$SKIP_DAFNY" == "true" ]]; then
    warn "Skipping Dafny installation (--skip-dafny)."
else
    step "Installing Dafny..."
    bash "$PLUGIN_ROOT/scripts/install-dafny.sh"
fi

# ── 4. Verify environment ─────────────────────────────────────────────────────
step "Verifying dependencies..."
bash "$PLUGIN_ROOT/scripts/verify-deps.sh"

echo
info "Plugin installed. Available commands: /clarify, /prove, /code"
info "Run '/clarify' in Claude Code to start the workflow."
