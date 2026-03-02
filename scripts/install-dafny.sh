#!/usr/bin/env bash
# install-dafny.sh — Install Dafny formal verification tool
#
# Usage:
#   bash scripts/install-dafny.sh            # install latest stable
#   DAFNY_VERSION=4.4.0 bash scripts/install-dafny.sh
#
# Supports: Linux (x64/arm64), macOS (x64/arm64)
# Requires: curl, unzip (or dotnet if using the .NET tool path)

set -euo pipefail

DAFNY_VERSION="${DAFNY_VERSION:-4.6.0}"
INSTALL_METHOD="${INSTALL_METHOD:-auto}"  # auto | dotnet | binary | brew

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()    { echo -e "${GREEN}[dafny-install]${NC} $*"; }
warn()    { echo -e "${YELLOW}[dafny-install]${NC} $*"; }
error()   { echo -e "${RED}[dafny-install] ERROR:${NC} $*" >&2; exit 1; }

# ── Already installed? ──────────────────────────────────────────────────────
if command -v dafny &>/dev/null; then
    INSTALLED=$(dafny --version 2>/dev/null | head -1 || echo "unknown")
    info "Dafny already installed: $INSTALLED"
    info "To reinstall, uninstall first or set a different DAFNY_VERSION."
    exit 0
fi

# ── Detect OS and architecture ───────────────────────────────────────────────
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
    Linux)  PLATFORM="linux" ;;
    Darwin) PLATFORM="macos" ;;
    *)      error "Unsupported OS: $OS. Install Dafny manually from https://github.com/dafny-lang/dafny/releases" ;;
esac

case "$ARCH" in
    x86_64)  ARCH_LABEL="x64" ;;
    aarch64|arm64) ARCH_LABEL="arm64" ;;
    *)       warn "Unrecognised architecture $ARCH, attempting x64 binary." ; ARCH_LABEL="x64" ;;
esac

# ── Select install method ────────────────────────────────────────────────────
if [[ "$INSTALL_METHOD" == "auto" ]]; then
    if [[ "$PLATFORM" == "macos" ]] && command -v brew &>/dev/null; then
        INSTALL_METHOD="brew"
    elif command -v dotnet &>/dev/null; then
        INSTALL_METHOD="dotnet"
    else
        INSTALL_METHOD="binary"
    fi
    info "Auto-selected install method: $INSTALL_METHOD"
fi

# ── Install via Homebrew (macOS) ─────────────────────────────────────────────
install_via_brew() {
    info "Installing Dafny via Homebrew..."
    brew install dafny
}

# ── Install via .NET global tool ─────────────────────────────────────────────
install_via_dotnet() {
    info "Installing Dafny $DAFNY_VERSION via dotnet tool..."

    # Ensure dotnet tools directory is on PATH
    DOTNET_TOOLS="${DOTNET_ROOT:-$HOME/.dotnet}/tools"
    if [[ ":$PATH:" != *":$DOTNET_TOOLS:"* ]]; then
        export PATH="$DOTNET_TOOLS:$PATH"
        SHELL_RC="$HOME/.bashrc"
        [[ -f "$HOME/.zshrc" ]] && SHELL_RC="$HOME/.zshrc"
        echo "export PATH=\"$DOTNET_TOOLS:\$PATH\"" >> "$SHELL_RC"
        warn "Added $DOTNET_TOOLS to PATH in $SHELL_RC. Restart your shell or run: source $SHELL_RC"
    fi

    dotnet tool install --global Dafny --version "$DAFNY_VERSION" 2>/dev/null \
        || dotnet tool update  --global Dafny --version "$DAFNY_VERSION"
}

# ── Install via pre-built binary (GitHub releases) ───────────────────────────
install_via_binary() {
    info "Installing Dafny $DAFNY_VERSION from GitHub releases..."

    # Map to GitHub release asset name
    case "${PLATFORM}-${ARCH_LABEL}" in
        linux-x64)    ASSET="dafny-${DAFNY_VERSION}-x64-ubuntu-20.04.zip" ;;
        linux-arm64)  ASSET="dafny-${DAFNY_VERSION}-arm64-ubuntu-20.04.zip" ;;
        macos-x64)    ASSET="dafny-${DAFNY_VERSION}-x64-macos-12.zip" ;;
        macos-arm64)  ASSET="dafny-${DAFNY_VERSION}-arm64-macos-12.zip" ;;
        *)            error "No binary release for ${PLATFORM}-${ARCH_LABEL}. Use INSTALL_METHOD=dotnet instead." ;;
    esac

    URL="https://github.com/dafny-lang/dafny/releases/download/v${DAFNY_VERSION}/${ASSET}"
    INSTALL_DIR="${DAFNY_INSTALL_DIR:-$HOME/.local/dafny}"
    TMP_DIR="$(mktemp -d)"

    info "Downloading $URL ..."
    curl -fsSL "$URL" -o "$TMP_DIR/dafny.zip" \
        || error "Download failed. Check your internet connection or visit https://github.com/dafny-lang/dafny/releases"

    info "Extracting to $INSTALL_DIR ..."
    mkdir -p "$INSTALL_DIR"
    unzip -q "$TMP_DIR/dafny.zip" -d "$INSTALL_DIR"
    rm -rf "$TMP_DIR"

    # Create symlink in a directory on PATH
    BIN_DIR="$HOME/.local/bin"
    mkdir -p "$BIN_DIR"
    ln -sf "$INSTALL_DIR/dafny" "$BIN_DIR/dafny"

    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        export PATH="$BIN_DIR:$PATH"
        SHELL_RC="$HOME/.bashrc"
        [[ -f "$HOME/.zshrc" ]] && SHELL_RC="$HOME/.zshrc"
        echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$SHELL_RC"
        warn "Added $BIN_DIR to PATH in $SHELL_RC. Restart your shell or run: source $SHELL_RC"
    fi
}

# ── .NET SDK installer (needed for dotnet method) ────────────────────────────
ensure_dotnet() {
    if command -v dotnet &>/dev/null; then
        return
    fi
    info ".NET SDK not found. Installing via Microsoft install script..."
    DOTNET_INSTALL_DIR="${DOTNET_ROOT:-$HOME/.dotnet}"
    curl -fsSL https://dot.net/v1/dotnet-install.sh \
        | bash -s -- --channel 8.0 --install-dir "$DOTNET_INSTALL_DIR"
    export DOTNET_ROOT="$DOTNET_INSTALL_DIR"
    export PATH="$DOTNET_INSTALL_DIR:$PATH"
    SHELL_RC="$HOME/.bashrc"
    [[ -f "$HOME/.zshrc" ]] && SHELL_RC="$HOME/.zshrc"
    {
        echo "export DOTNET_ROOT=\"$DOTNET_INSTALL_DIR\""
        echo "export PATH=\"$DOTNET_INSTALL_DIR:\$PATH\""
    } >> "$SHELL_RC"
    warn ".NET SDK installed. Restart your shell or run: source $SHELL_RC"
}

# ── Run selected method ──────────────────────────────────────────────────────
case "$INSTALL_METHOD" in
    brew)   install_via_brew ;;
    dotnet) ensure_dotnet; install_via_dotnet ;;
    binary) install_via_binary ;;
    *)      error "Unknown INSTALL_METHOD: $INSTALL_METHOD. Use auto, brew, dotnet, or binary." ;;
esac

# ── Verify ───────────────────────────────────────────────────────────────────
if command -v dafny &>/dev/null; then
    INSTALLED=$(dafny --version 2>/dev/null | head -1 || echo "unknown")
    info "Dafny installed successfully: $INSTALLED"
else
    warn "Dafny binary not found on current PATH."
    warn "You may need to restart your shell, then run: dafny --version"
fi
