#!/usr/bin/env bash
set -euo pipefail

prefix="${PREFIX:-/usr/local}"
bindir="$prefix/bin"

mkdir -p "$bindir"

install -m 0755 bin/ccprofile "$bindir/ccprofile"
install -m 0755 bin/ccrun "$bindir/ccrun"
install -m 0755 bin/ccenv "$bindir/ccenv"
install -m 0755 bin/claude-docker "$bindir/claude-docker"

echo "Installed cc-profile commands to $bindir"
echo "Commands: ccprofile, ccrun, ccenv, claude-docker"
