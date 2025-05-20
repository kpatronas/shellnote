#!/bin/bash

set -e

SCRIPT_SOURCE="shellnote.sh"
SCRIPT_TARGET="shellnote"
LOCAL_DIR="$HOME/.shellnote"
LOCAL_PATH="$LOCAL_DIR/$SCRIPT_TARGET"
SYSTEM_PATH="/usr/local/bin/$SCRIPT_TARGET"

# Lines to be added to .bashrc/.zshrc (in proper order)
PATH_LINE='export PATH="$HOME/.shellnote:$PATH"'
STARTUP_BLOCK=$(cat <<'EOF'
# Run shellnote on terminal start (interactive only)
if [[ $- == *i* ]]; then
    if command -v shellnote >/dev/null 2>&1; then
        shellnote
    fi
fi
EOF
)

echo "🔧 Starting ShellNote installation..."

if [[ "$EUID" -eq 0 ]]; then
    echo "📦 Performing system-wide install to /usr/local/bin"

    if [ ! -f "./$SCRIPT_SOURCE" ]; then
        echo "❌ Error: $SCRIPT_SOURCE not found in current directory."
        exit 1
    fi

    cp "./$SCRIPT_SOURCE" "$SYSTEM_PATH"
    chmod +x "$SYSTEM_PATH"

    echo "✅ Installed as /usr/local/bin/shellnote"
    echo "🧪 Try: shellnote --listall"

else
    echo "👤 Performing local install for user: $USER"

    mkdir -p "$LOCAL_DIR"

    if [ ! -f "./$SCRIPT_SOURCE" ]; then
        echo "❌ Error: $SCRIPT_SOURCE not found in current directory."
        exit 1
    fi

    cp "./$SCRIPT_SOURCE" "$LOCAL_PATH"
    chmod +x "$LOCAL_PATH"
    echo "✅ Installed to $LOCAL_PATH"

    RC_FILES=("$HOME/.bashrc" "$HOME/.zshrc")
    for rc in "${RC_FILES[@]}"; do
        if [ -f "$rc" ]; then
            grep -qxF "$PATH_LINE" "$rc" || echo "$PATH_LINE" >> "$rc"
            grep -qxF "$STARTUP_BLOCK" "$rc" || echo "$STARTUP_BLOCK" >> "$rc"
            echo "📎 Updated $rc with PATH and startup hook"
        fi
    done

    echo "✅ Local install complete."
    echo "💡 Run: source ~/.bashrc or source ~/.zshrc"
    echo "🧪 Then try: shellnote --listall"
fi
