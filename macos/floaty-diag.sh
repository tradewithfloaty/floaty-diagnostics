#!/bin/sh
# Floaty macOS diagnostic.
#
# This script does not install, change or delete anything, and it does not send
# your data anywhere. It prints a report in your terminal.
#
# Source: https://github.com/tradewithfloaty/floaty-diagnostics

LABEL="com.floaty.core"
AGENTS="$HOME/Library/LaunchAgents"
PLIST="$AGENTS/$LABEL.plist"
APPSUP="$HOME/Library/Application Support/Floaty"

# The installed app, in either Applications folder.
APP=""
for candidate in /Applications/Floaty.app "$HOME/Applications/Floaty.app"; do
	if [ -e "$candidate" ]; then
		APP="$candidate"
		break
	fi
done

# Report one path as writable, not writable, or absent.
writable() {
	if [ ! -e "$2" ]; then
		printf '  --    %-26s %s\n' "$1" "(not created yet)"
	elif [ -w "$2" ]; then
		printf '  ok    %-26s %s\n' "$1" "$2"
	else
		printf '  FAIL  %-26s %s\n' "$1" "$2"
	fi
}

echo "Floaty macOS diagnostic"
echo "macOS $(sw_vers -productVersion) build $(sw_vers -buildVersion)   $(uname -m)   user $(id -un)   uid $(id -u)"
echo

echo "Versions"
if [ -n "$APP" ]; then
	printf '  app              %s   %s\n' \
		"$(defaults read "$APP/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo unknown)" "$APP"
	printf '  core in app      %s\n' "$(cat "$APP/Contents/Resources/core/version.txt" 2>/dev/null || echo unknown)"
else
	echo "  Floaty.app is not in /Applications or ~/Applications"
fi
installed="$(readlink "$APPSUP/core/current" 2>/dev/null)"
if [ -n "$installed" ]; then
	printf '  core installed   %s\n' "$(basename "$installed")"
else
	printf '  core installed   none\n'
fi
echo

# Each line below is one step of Floaty's startup. The first FAIL is the cause.
echo "Permissions Floaty needs at startup"
writable "app support"      "$HOME/Library/Application Support"
writable "Floaty data"      "$APPSUP"
writable "LaunchAgents dir" "$AGENTS"
writable "LaunchAgent file" "$PLIST"
if [ -x /bin/launchctl ]; then
	printf '  ok    %-26s %s\n' "launchctl" "/bin/launchctl"
else
	printf '  FAIL  %-26s %s\n' "launchctl" "/bin/launchctl"
fi
echo

echo "Ownership (Floaty writes these as you, not as an administrator)"
[ -n "$APP" ] && ls -ld "$APP"
ls -d /Volumes/*/Floaty.app 2>/dev/null && echo "  note: a copy is on a mounted disk image"
ls -ld "$AGENTS" "$APPSUP" 2>&1
ls -l "$PLIST" 2>&1
echo

echo "Core daemon"
ls -l "$APPSUP/core/" 2>&1
launchctl print "gui/$(id -u)/$LABEL" 2>&1 | head -5
echo

echo "Managed device"
profiles status -type enrollment 2>&1 | head -3
echo

echo "Log files (encrypted; send the newest if asked)"
ls -lt "$APPSUP/logs/" 2>&1 | head -4
