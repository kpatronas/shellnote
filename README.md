# 🗒️ ShellNote — Terminal Sticky Notes with Auto-Expiration
ShellNote is a lightweight, terminal-based sticky notes system written in Bash. Easily add, view, and delete notes that automatically expire after a set time.

✨ Features
✅ Create sticky notes with natural expiration times (e.g. 10m, 2h, 1d)

🧼 Auto-expire old notes based on real time

📋 List only active (non-expired) notes, or all notes

🗑️ Interactive deletion via numbered menu

🖥️ Optional: Display notes on terminal startup

📦 System-wide or per-user installation support

🚀 Installation Options

✅ Option 1: Per-user (local) install

```
chmod +x install.sh
./install.sh
```
This will:

Move shellnote.sh to ~/.shellnote/shellnote.sh

Add ~/.shellnote to your PATH

Auto-run ShellNote when a terminal starts by modifying ~/.bashrc or ~/.zshrc

💡 Reload your terminal or run source ~/.bashrc (or ~/.zshrc) to apply changes.


✅ Option 2: System-wide install (for all users)

```
sudo ./install.sh
```
This will:

Copy shellnote.sh to /usr/local/bin/shellnote

Make it executable globally

Append automatic ShellNote execution to /etc/bash.bashrc and /etc/zsh/zshrc

🧪 You can now run shellnote from any terminal, for any user.

⚙️ Usage
➕ Add a new note
```
shellnote --new "Drink water" --expire 1h
```
Valid time formats:

* 5m → 5 minutes

* 2h → 2 hours

* 1d → 1 day

📋 View active (non-expired) notes
```
shellnote
```
📜 View all notes (active + expired)
```
shellnote --listall
```
🗑️ Delete a note interactively
```
shellnote --delete
```
You'll see a menu to choose which note to delete.

🧠 Auto-run on Terminal Start (Optional)
This is added automatically during install. To do it manually:

Add this to your .bashrc, .zshrc, or system-wide shell config:
```
if command -v shellnote >/dev/null 2>&1; then
    shellnote
fi
```
📁 Note Storage
Notes are saved as .txt files in:

Per-user install: ~/.shellnote/

System-wide install: still saved under each user’s ~/.shellnote/

File format (comma-separated):
```
<created_epoch>,<expire_epoch>,<note content>
```
🧹 Future Ideas
⏱ Auto-clean expired notes

🔐 Encrypted notes

🖼 GUI or desktop notification integration

📦 .deb packaging

🛠 Uninstall (Manual)
For local install:
```
rm -rf ~/.shellnote
sed -i '/shellnote.sh/d' ~/.bashrc ~/.zshrc
```
For system-wide install:
```
sudo rm /usr/local/bin/shellnote
sudo sed -i '/shellnote/d' /etc/bash.bashrc /etc/zsh/zshrc
```
