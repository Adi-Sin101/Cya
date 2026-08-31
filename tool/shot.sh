#!/usr/bin/env bash
# Screenshot the running app into build/verification/<name>.png.
#
# adb over Git Bash mangles /sdcard paths unless MSYS_NO_PATHCONV is set, and
# `adb exec-out > file` corrupts PNGs on Windows — hence the shell redirect on
# the device followed by a pull (see PRD §13.4 tooling notes).
set -euo pipefail
export MSYS_NO_PATHCONV=1
name="${1:-shot}"
wait="${2:-2}"
mkdir -p build/verification
sleep "$wait"
adb shell "screencap -p > /sdcard/_shot.png"
adb pull /sdcard/_shot.png "build/verification/${name}.png" >/dev/null
echo "build/verification/${name}.png"
