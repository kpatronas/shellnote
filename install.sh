#!/bin/bash

set -e

SCRIPT_NAME="shellnote.sh"
INSTALL_PATH="/usr/local/bin/shellnote"

echo "🔧 Installing ShellNote system-wide to /usr/local/bin..."

# Check if run as root or with sudo
if [[ "$EUID" -ne 0 ]]; then
    echo "❌ Please run this script with sudo or as root."
    exit 1
fi

# Check if the script exists in the current directory
if [ ! -f "./$SCRIPT_NAME" ]; then
    echo "❌ Error: $SCRIPT_NAME not found in the current directory."
    exit 1
fi

# Copy the script to /usr/local/bin and make it executable
cp "./$SCRIPT_NAME" "$INSTALL_PATH"
chmod +x "$INSTALL_PATH"

echo "✅ Installed to $INSTALL_PATH"
echo "📌 You can now run 'shellnote' from anywhere."

# Optional: Add to all users' shell startup files to auto-show notes
RC_FILES=("/etc/bash.bashrc" "/etc/zsh/zshrc")
STARTUP_LINE='if command -v shellnote >/dev/null 2>&1; then shellnote; fi'

for rc in "${RC_FILES[@]}"; do
    if [ -f "$rc" ]; then
        grep -qxF "$STARTUP_LINE" "$rc" || echo "$STARTUP_LINE" >> "$rc"
        echo "📎 Added auto-run to $rc"
    fi
done

echo ""
echo "✅ System-wide installation complete."
echo "🧪 Test it now: type 'shellnote --listall'"
