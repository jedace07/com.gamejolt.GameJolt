#!/bin/sh
set -eu

cd /app/lib/game-jolt-client
exec ./game-jolt-client --class=com.gamejolt.GameJolt "$@"
