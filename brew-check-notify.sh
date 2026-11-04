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

BREW="/opt/homebrew/bin/brew"

"$BREW" update >/dev/null 2>&1

OUTDATED=$("$BREW" outdated 2>/dev/null)
CASKS=$("$BREW" outdated --cask 2>/dev/null)

if [[ -n "$OUTDATED" || -n "$CASKS" ]]; then
    COUNT=$(printf "%s\n%s\n" "$OUTDATED" "$CASKS" |
        grep -c .)

    osascript -e "display notification \"$COUNT Homebrew updates available\" with title \"Homebrew Update Check\""
fi
