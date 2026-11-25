#!/bin/bash
# Downloads the official Game Jolt client on first launch, then runs it.
# The client's own loader keeps it updated in the app's data directory.
set -euo pipefail

api=https://gamejolt.com/site-api
client_dir="${XDG_DATA_HOME:-$HOME/.local/share}/game-jolt-client"
loader="$client_dir/game-jolt-client"

if [ -x "$loader" ] && [ -f "$client_dir/.manifest" ]; then
	cd "$client_dir"
	exec "$loader" "$@"
fi

fail() {
	printf 'game-jolt-client: %s\n' "$1" >&2
	if [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]; then
		zenity --error --title="Game Jolt" --text="$1" 2>/dev/null || true
	fi
	exit 1
}

download_client() {
	local staging=$1 build_info build_id expected_size download_url archive

	build_info=$(curl -fsSL --retry 3 "$api/web/landing/app" |
		python3 -I -c '
import json, sys
builds = json.load(sys.stdin)["payload"]["packageData"]["builds"]
linux = [b for b in builds if b["primary_file"]["filename"] == "gamejoltclient.tar.gz"]
if len(linux) != 1:
    sys.exit("Expected one Linux client build, found %d" % len(linux))
print(linux[0]["id"], linux[0]["primary_file"]["filesize"])
') || return 1
	read -r build_id expected_size <<<"$build_info"

	download_url=$(curl -fsSL --retry 3 -X POST -H 'Content-Type: application/json' -d '{}' \
		"$api/web/discover/games/builds/get-download-url/$build_id" |
		python3 -I -c '
import json, sys
url = json.load(sys.stdin)["payload"]["url"]
if not url.startswith("https://download.gamejolt.net/"):
    sys.exit("Unexpected download host")
print(url)
') || return 1

	archive="$staging/gamejoltclient.tar.gz"
	curl -fL --retry 3 -o "$archive" "$download_url" || return 1
	[ "$(stat -c %s "$archive")" = "$expected_size" ] || return 1

	tar -xzf "$archive" -C "$staging" --no-same-owner || return 1
	rm "$archive"
	[ -x "$staging/game-jolt-client" ] && [ -f "$staging/.manifest" ]
}

mkdir -p "$(dirname "$client_dir")"
staging=$(mktemp -d "$client_dir.download.XXXXXX")
trap 'rm -rf "$staging"' EXIT

progress_fd=
if [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ] && command -v zenity >/dev/null; then
	exec {progress_fd}> >(zenity --progress --pulsate --no-cancel --auto-close --title="Game Jolt" \
		--text="Downloading the Game Jolt client…" 2>/dev/null)
fi

download_status=0
download_client "$staging" || download_status=$?
if [ -n "$progress_fd" ]; then
	{ echo 100 >&"$progress_fd"; } 2>/dev/null || true
	exec {progress_fd}>&-
fi
[ "$download_status" = 0 ] || fail "Could not download the Game Jolt client. Check your connection and try again."

# Keep an incomplete earlier download for inspection instead of deleting it.
if [ -e "$client_dir" ]; then
	mv "$client_dir" "$client_dir.incomplete.$(date +%Y%m%d%H%M%S)"
fi
mv "$staging" "$client_dir"
trap - EXIT

cd "$client_dir"
exec "$loader" "$@"
