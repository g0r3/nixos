#!/usr/bin/env bash
#
# install-nix.sh
# Bootstraps a macOS machine with Nix and nix-darwin from this repository.
#

set -euo pipefail

# --- Constants & Configuration ---
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FLAKE_Target="macbook-pro"

# --- Logging Functions ---
log_info() { echo -e "\033[1;34m[INFO]\033[0m $*"; }
log_warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
log_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $*"
    exit 1
}

# --- Pre-flight Checks ---

# 1. Check Root Privileges
if [ "$EUID" -ne 0 ]; then
    log_error "This script must be run as root (sudo)."
fi

# 2. Check Repository Context
if [ ! -f "${REPO_ROOT}/flake.nix" ]; then
    log_error "Could not locate 'flake.nix' at repo root: ${REPO_ROOT}"
fi

log_info "Starting bootstrap from: ${REPO_ROOT}"

# --- Step 1: Install Rosetta 2 ---
if /usr/bin/pgrep oahd >/dev/null 2>&1; then
    log_info "Rosetta 2 is already running."
else
    log_info "Installing Rosetta 2..."
    /usr/sbin/softwareupdate --install-rosetta --agree-to-license
fi

# --- Step 2: Install Nix Package Manager ---
if command -v nix >/dev/null 2>&1; then
    log_info "Nix is already installed."
else
    log_info "Installing Nix (Official Installer)..."
    rm -f /etc/zshrc.backup-before-nix
    rm -f /etc/bashrc.bashrc.backup-before-nix
    curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes
fi

# Source Nix environment for the current session
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    set +u # Nix script might use unbound vars
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    set -u
fi

# --- Step 3: Prepare for Nix-Darwin ---
# nix-darwin wants to manage /etc/zshrc and /etc/bashrc.
# If they exist as regular files, the activation will fail.
log_info "Preparing /etc for nix-darwin..."
rm -f /etc/zshrc
rm -f /etc/bashrc

# --- Step 4: Bootstrap Nix-Darwin ---
log_info "Building and switching to flake: .#${FLAKE_Target}"

# Ensure we are in the repo root for the flake command
cd "${REPO_ROOT}"

nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ".#${FLAKE_Target}"

# --- Completion ---
echo ""
log_info "Bootstrap complete!"
log_info "Please close and reopen your terminal to ensure all environment variables are loaded."
