#!/usr/bin/env bash
#
# uninstall-nix.sh
# Completely removes Nix, nix-darwin, and the /nix volume from macOS.
#

set -euo pipefail

# --- Logging Functions ---
log_info() { echo -e "\033[1;34m[INFO]\033[0m $*"; }
log_warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
log_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $*"
    exit 1
}

# --- Pre-flight Checks ---
if [ "$EUID" -ne 0 ]; then
    log_error "This script must be run as root (sudo)."
fi

log_warn "This script will completely uninstall Nix and delete the /nix volume."
log_warn "This action is irreversible."
read -p "Are you sure? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Uninstall cancelled."
    exit 0
fi

# --- Step 1: Restore System Shell Configs ---
restore_file() {
    local backup="$1"
    local target="$2"
    if [ -f "$backup" ]; then
        log_info "Restoring $target from $backup..."
        mv "$backup" "$target"
    else
        log_warn "Backup file $backup not found. Skipping restore for $target."
    fi
}

restore_file "/etc/zshrc.pre-nix.bak" "/etc/zshrc"
restore_file "/etc/bashrc.pre-nix.bak" "/etc/bashrc"

# Also clean up any other backup leftovers mentioned in original script
rm -f /etc/bash.bashrc.backup-before-nix
rm -f /etc/bashrc.backup-before-nix

# --- Step 2: Unload and Remove LaunchDaemons ---
remove_daemon() {
    local plist="$1"
    if [ -f "$plist" ]; then
        log_info "Unloading and removing $plist..."
        launchctl unload "$plist" 2>/dev/null || true
        rm "$plist"
    fi
}

remove_daemon "/Library/LaunchDaemons/org.nixos.nix-daemon.plist"
remove_daemon "/Library/LaunchDaemons/org.nixos.darwin-store.plist"

# --- Step 3: Remove Nix Users and Groups ---
log_info "Removing Nix build users and groups..."
dscl . -delete /Groups/nixbld 2>/dev/null || true
for u in $(dscl . -list /Users | grep _nixbld); do
    sudo dscl . -delete /Users/"$u"
done

# --- Step 4: Clean up fstab (vifs) ---
log_info "Removing /nix mount from fstab..."
TMP_EDITOR=$(mktemp /tmp/fstab_editor.XXXXXX)
chmod +x "$TMP_EDITOR"

# Create a temporary editor script that deletes lines containing '/nix'
cat <<EOF >"$TMP_EDITOR"
#!/bin/bash
sed -i '' '/nix/d' "\$1"
EOF

# Run vifs with the temp editor
EDITOR="$TMP_EDITOR" /usr/sbin/vifs 2>/dev/null || true
rm "$TMP_EDITOR"

# --- Step 5: Clean up synthetic.conf ---
if [ -f /etc/synthetic.conf ]; then
    log_info "Cleaning /etc/synthetic.conf..."
    if grep -q "^nix$" /etc/synthetic.conf; then
        # If the file strictly contains "nix", delete it
        if [ "$(tr -d '[:space:]' </etc/synthetic.conf)" = "nix" ]; then
            rm /etc/synthetic.conf
        else
            # Otherwise just remove the line
            sed -i '' '/^nix/d' /etc/synthetic.conf
        fi
    fi
fi

# --- Step 6: Delete Configuration & Profiles ---
log_info "Removing Nix configuration and profiles..."
rm -rf /etc/nix /var/root/.nix-profile /var/root/.nix-defexpr /var/root/.nix-channels ~/.nix-profile ~/.nix-defexpr ~/.nix-channels

# --- Step 7: Delete /nix Volume ---
if [ -d "/nix" ]; then
    log_info "Deleting /nix APFS volume..."
    /usr/sbin/diskutil apfs deleteVolume /nix || log_warn "Failed to delete /nix volume via diskutil. It might require manual removal."
else
    log_info "/nix directory/volume does not exist."
fi

# --- Step 8: Verification ---
log_info "Verifying cleanup..."
if /usr/sbin/diskutil list | grep -q " /nix"; then
    log_error "Uninstall FAILED. The /nix volume is still present in 'diskutil list'."
else
    log_info "Uninstall COMPLETE. Nix has been successfully removed."
fi

