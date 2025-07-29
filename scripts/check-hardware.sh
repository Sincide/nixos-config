#!/usr/bin/env bash
set -e
missing=0
for host in hosts/*; do
  if [ -d "$host" ] && [ ! -f "$host/hardware-configuration.nix" ]; then
    echo "Missing hardware configuration for $(basename "$host")" >&2
    missing=1
  fi
done
exit $missing
