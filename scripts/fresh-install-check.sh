#!/usr/bin/env bash

echo "🔍 Fresh Installation Pre-flight Check"
echo "======================================"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not in a git repository"
    echo "   Run: git init && git add . && git commit -m 'Initial commit'"
    exit 1
fi

# Check git status
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "⚠️  Git tree is dirty (uncommitted changes)"
    echo "   This may cause flake issues. Consider committing changes:"
    echo "   git add . && git commit -m 'Pre-rebuild commit'"
else
    echo "✅ Git tree is clean"
fi

# Check if hardware-configuration.nix exists and is not placeholder
HARDWARE_CONFIG="hosts/nixos/hardware-configuration.nix"
if [[ -f "$HARDWARE_CONFIG" ]]; then
    if grep -q "Placeholder hardware configuration" "$HARDWARE_CONFIG"; then
        echo "❌ Hardware configuration is still placeholder"
        echo "   Run: sudo nixos-generate-config --show-hardware-config > $HARDWARE_CONFIG"
        exit 1
    else
        echo "✅ Hardware configuration exists and looks valid"
    fi
else
    echo "❌ Hardware configuration missing"
    echo "   Run: sudo nixos-generate-config --show-hardware-config > $HARDWARE_CONFIG"
    exit 1
fi

# Check network connectivity for flake inputs
echo "🌐 Checking network connectivity for flake dependencies..."

INPUTS=(
    "github.com"
    "api.github.com"
)

for input in "${INPUTS[@]}"; do
    if curl -s --connect-timeout 5 "https://$input" > /dev/null; then
        echo "✅ $input reachable"
    else
        echo "⚠️  $input unreachable - flake updates may fail"
    fi
done

# Check if flake.lock exists
if [[ -f "flake.lock" ]]; then
    echo "✅ flake.lock exists (using cached dependencies)"
else
    echo "⚠️  flake.lock missing - will fetch all dependencies fresh"
fi

echo ""
echo "🎯 Pre-flight check complete!"
echo ""
echo "To proceed with NixOS rebuild:"
echo "  sudo nixos-rebuild switch --flake .#nixos"
echo ""
echo "If rebuild fails with fetch errors, try:"
echo "  sudo nixos-rebuild switch --flake .#nixos --option narHash-mismatch-warn true"