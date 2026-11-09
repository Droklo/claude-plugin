#!/bin/sh
# Droklo plugin, SessionStart hook (Claude Code and Cowork; claude.ai chat
# ignores plugin hooks). Says when a newer Droklo plugin is out: it compares
# this plugin's version with the one Droklo publishes, checks the network at
# most once a day (cached in CLAUDE_PLUGIN_DATA) and tells the user about a
# given version at most once a day. Prints nothing otherwise and always
# exits 0, so it never gets in the way of a session.
#
# Opt out: DROKLO_NO_UPDATE_CHECK=1. Tests: DROKLO_MARKETPLACE_URL overrides
# where the latest version is read from (any URL curl accepts, file:// too).

[ -n "${DROKLO_NO_UPDATE_CHECK:-}" ] && exit 0

ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)}"
DATA="${CLAUDE_PLUGIN_DATA:-${TMPDIR:-/tmp}/droklo-plugin}"
URL="${DROKLO_MARKETPLACE_URL:-https://www.droklo.com/downloads/marketplace.json}"
DAY=86400

# First "version": "x.y.z" in a JSON text on stdin.
first_version() {
  sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)".*/\1/p' | head -n 1
}

installed=$(first_version < "$ROOT/.claude-plugin/plugin.json" 2>/dev/null)
[ -n "$installed" ] || exit 0
mkdir -p "$DATA" 2>/dev/null || exit 0

now=$(date +%s)
cache="$DATA/latest-version" # "<checked-epoch> <version>"
checked=0
latest=""
if [ -f "$cache" ]; then
  read -r checked latest < "$cache" 2>/dev/null || true
  case "$checked" in '' | *[!0-9]*) checked=0 ;; esac
fi

if [ -z "$latest" ] || [ $((now - checked)) -ge $DAY ]; then
  fetched=$(curl -fsSL --max-time 4 "$URL" 2>/dev/null | first_version)
  if [ -n "$fetched" ]; then
    latest=$fetched
    printf '%s %s\n' "$now" "$latest" > "$cache" 2>/dev/null
  fi
fi
[ -n "$latest" ] || exit 0

# 1 when $2 is a newer x.y.z than $1.
newer=$(awk -v a="$installed" -v b="$latest" 'BEGIN {
  split(a, x, "."); split(b, y, ".");
  for (i = 1; i <= 3; i++) {
    if (y[i] + 0 > x[i] + 0) { print 1; exit }
    if (y[i] + 0 < x[i] + 0) { print 0; exit }
  }
  print 0
}')
[ "$newer" = "1" ] || exit 0

notified="$DATA/notified" # "<version> <yyyy-mm-dd>"
today=$(date +%Y-%m-%d)
if [ -f "$notified" ] && [ "$(cat "$notified" 2>/dev/null)" = "$latest $today" ]; then
  exit 0
fi
printf '%s %s\n' "$latest" "$today" > "$notified" 2>/dev/null

printf '{"systemMessage":"Droklo plugin %s is out (you have %s). Update it: /plugin, then Marketplaces, droklo, Update, and run /reload-plugins. Select Enable auto-update there to get new versions by themselves.","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"Droklo plugin update available: installed %s, latest %s. The user updates it with /plugin (Marketplaces, droklo, Update) and /reload-plugins."}}\n' \
  "$latest" "$installed" "$installed" "$latest"
exit 0
