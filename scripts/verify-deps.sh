#!/usr/bin/env bash
# verify-deps.sh — Check that all tools required by clarify-prove-code are present
#
# Usage:
#   bash scripts/verify-deps.sh
#
# Exit codes:
#   0  all required tools found
#   1  one or more required tools missing

set -uo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "  ${GREEN}✓${NC} $*"; }
fail() { echo -e "  ${RED}✗${NC} $*"; }
warn() { echo -e "  ${YELLOW}?${NC} $*"; }

MISSING=0

echo "Checking required tools..."
echo

# ── Dafny (required for Prove phase) ─────────────────────────────────────────
if command -v dafny &>/dev/null; then
    VERSION=$(dafny --version 2>/dev/null | head -1 || echo "version unknown")
    ok "dafny   — $VERSION"
else
    fail "dafny   — NOT FOUND"
    echo "         Install with: bash scripts/install-dafny.sh"
    MISSING=$((MISSING + 1))
fi

# ── .NET (optional; needed if Dafny was installed via dotnet tool) ────────────
if command -v dotnet &>/dev/null; then
    VERSION=$(dotnet --version 2>/dev/null || echo "version unknown")
    ok "dotnet  — $VERSION"
else
    warn "dotnet  — not found (only required if using INSTALL_METHOD=dotnet)"
fi

echo

# ── Optional language runtimes (informational only) ──────────────────────────
echo "Checking optional language runtimes (Tier 1)..."
echo

for tool in python3 node tsc rustc go javac gcc g++; do
    if command -v "$tool" &>/dev/null; then
        VERSION=$("$tool" --version 2>/dev/null | head -1 || echo "version unknown")
        ok "$tool — $VERSION"
    else
        warn "$tool — not found"
    fi
done

echo

# ── Result ────────────────────────────────────────────────────────────────────
if [[ "$MISSING" -gt 0 ]]; then
    echo -e "${RED}$MISSING required tool(s) missing.${NC} See instructions above."
    exit 1
else
    echo -e "${GREEN}All required tools are present.${NC}"
    exit 0
fi
