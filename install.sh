#!/bin/bash

set -e

SCRIPT_NAME="shellnote.sh"
LOCAL_DIR="$HOME/.shellnote"
LOCAL_PATH="$LOCAL_DIR/$SCRIPT_NAME"
SYSTEM_PATH="/usr/local/bin/shellnote"
STARTUP_LINE='if command -v shellnote >/dev/null 2>&1; then shellnote; fi'
PATH_LINE='export PATH="$HOME/.shellnote:$PATH"'
ALIAS_LINE='alias shellnote="shellnote.sh"'

echo "🔧 Starting ShellNote installation..."

if [[ "$EUID" -eq 0 ]]; then
    echo "📦 Performing system-wide install to /usr/local/bin"

    if [ ! -f "./$SCRIPT_NAME" ]; then
        echo "❌ Error: $SCRIPT_NAME not found in current directory."
        exit 1
    fi

    cp "./$SCRIPT_NAME" "$SYSTEM_PATH"
    chmod +x "$SYSTEM_PATH"

    echo "✅ Installed to $SYSTEM_PATH"
    echo "ℹ️ No shell config files were modified."
    echo "🧪 You can now run 'shellnote' globally."

else
    echo "👤 Performing local install for user: $USER"

    mkdir -p "$LOCAL_DIR"

    if [ ! -f "./$SCRIPT_NAME" ]; then
        echo "❌ Error: $SCRIPT_NAME not found in current directory."
        exit 1
    fi

    cp "./$SCRIPT_NAME" "$LOCAL_PATH"
    chmod +x "$LOCAL_PATH"
    echo "✅ Installed to $LOCAL_PATH"

    RC_FILES=("$HOME/.bashrc" "$HOME/.zshrc")
    for rc in "${RC_FILES[@]}"; do
        if [ -f "$rc" ]; then
            grep -qxF "$PATH_LINE" "$rc" || echo "$PATH_LINE" >> "$rc"
            grep -qxF "$ALIAS_LINE" "$rc" || echo "$ALIAS_LINE" >> "$rc"
            grep -qxF "$STARTUP_LINE" "$rc" || echo "$STARTUP_LINE" >> "$rc"
            echo "📎 Updated $rc with PATH, alias, and startup hook"
        fi
    done

    echo "✅ Local install complete."
    echo "💡 Run: source ~/.bashrc or ~/.zshrc"
    echo "🧪 Then try: shellnote --listall"
fi
