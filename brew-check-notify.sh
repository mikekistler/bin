#!/bin/zsh

# -----------------------------------------------------------------------------
# Homebrew Update Notification
#
# Purpose:
# Checks for outdated Homebrew formulae and casks and displays a macOS
# notification when updates are available.
#
# Behavior:
# - Refreshes Homebrew's package information with `brew update`.
# - Checks installed formulae and casks for available updates.
# - Notifies the user only when updates are found.
# - Does not install or upgrade any packages automatically.
#
# Scheduling:
# Intended to run weekly via a macOS LaunchAgent.
# The user can review available updates and install them manually using
# `brew upgrade` or `brew upgrade --cask`.
#
# Requirements:
# - Homebrew installed at /opt/homebrew/bin/brew (Apple Silicon).
# - macOS with notification support via osascript.
#
# -----------------------------------------------------------------------------

SEND_EMAIL=0
case "$1" in
    "") ;;
    --email) SEND_EMAIL=1 ;;
    *) echo "Usage: ${0:t} [--email]" >&2; exit 2 ;;
esac

BREW="/opt/homebrew/bin/brew"

"$BREW" update >/dev/null 2>&1

OUTDATED=$("$BREW" outdated 2>/dev/null)
CASKS=$("$BREW" outdated --cask 2>/dev/null)

HOSTNAME=$(scutil --get ComputerName)

if [[ -n "$OUTDATED" || -n "$CASKS" ]]; then
    COUNT=$(printf "%s\n%s\n" "$OUTDATED" "$CASKS" |
        grep -c .)
    SUBJECT="Homebrew updates available ($COUNT) on $HOSTNAME"
    BODY="The following Homebrew updates are available on $HOSTNAME

Formulae:
$OUTDATED

Casks:
$CASKS

To review and install updates, run:

brew outdated
brew upgrade"
else
    SUBJECT="Homebrew packages are up to date on $HOSTNAME"
    BODY="All Homebrew packages are up to date on $HOSTNAME."
fi

if (( ! SEND_EMAIL )); then
    printf "%s\n" "$SUBJECT"
    exit 0
fi

TO="kistlertx@gmail.com"

osascript - "$TO" "$SUBJECT" "$BODY" <<'APPLESCRIPT'
on run argv
    tell application "Mail"
        set msg to make new outgoing message with properties ¬
            {subject:item 2 of argv, content:item 3 of argv, visible:false}

        tell msg
            make new to recipient at end of to recipients with properties ¬
                {address:item 1 of argv}
            send
        end tell
    end tell
end run
APPLESCRIPT
