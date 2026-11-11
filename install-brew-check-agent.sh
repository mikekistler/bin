#!/bin/zsh

# -----------------------------------------------------------------------------
# Install Homebrew Update Check LaunchAgent
#
# Installs a weekly LaunchAgent that runs brew-check-notify every Monday
# at 9:00 AM. The script checks for Homebrew updates and emails a report
# when updates are available.
#
# Requirements:
#   ~/bin/brew-check-notify must already exist and be executable.
#
# Usage:
#   ./install-brew-check-agent
# -----------------------------------------------------------------------------

set -e

LABEL="com.mike.brew-check"
SCRIPT="$HOME/bin/brew-check-notify.sh"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

# Verify the update-check script exists.
if [[ ! -x "$SCRIPT" ]]; then
    echo "Error: $SCRIPT does not exist or is not executable."
    exit 1
fi

# Create the LaunchAgents directory if necessary.
mkdir -p "$HOME/Library/LaunchAgents"

# Create the LaunchAgent plist.
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC
 "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">

<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>

    <key>ProgramArguments</key>
    <array>
        <string>$SCRIPT</string>
        <string>--email</string>
    </array>

    <key>StartCalendarInterval</key>
    <dict>
        <key>Weekday</key>
        <integer>1</integer>
        <key>Hour</key>
        <integer>9</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
</dict>
</plist>
EOF

# Validate the plist.
plutil -lint "$PLIST"

# Unload an existing instance, if present.
launchctl bootout "gui/$(id -u)" "$PLIST" 2>/dev/null || true

# Load the LaunchAgent.
launchctl bootstrap "gui/$(id -u)" "$PLIST"

echo "Installed and loaded $LABEL"
echo "Schedule: Every Monday at 9:00 AM"
