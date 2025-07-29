#!/usr/bin/env fish

# qBittorrent-nox Status Script for Waybar
# Gets torrent stats, network speeds, and status from qBittorrent Web API

set -l api_url "http://127.0.0.1:9090/api/v2"
set -l username "admin"
set -l password "admin"

# Function to format bytes
function format_bytes
    set -l bytes $argv[1]
    if test -z "$bytes" -o "$bytes" = "0"
        echo "0B/s"
        return
    end
    
    if test $bytes -lt 1024
        printf "%.0fB/s" $bytes
    else if test $bytes -lt (math "1024 * 1024")
        printf "%.1fK/s" (math "$bytes / 1024")
    else if test $bytes -lt (math "1024 * 1024 * 1024")
        printf "%.1fM/s" (math "$bytes / 1024 / 1024")
    else
        printf "%.1fG/s" (math "$bytes / 1024 / 1024 / 1024")
    end
end

# Check if qbittorrent-nox is running
if not systemctl --user is-active --quiet qbittorrent-nox.service
    echo "⚠️ qBT: OFF"
    exit 0
end

# Get session cookie
set -l cookie_jar (mktemp)
set -l login_response (curl -s -c "$cookie_jar" -X POST \
    -d "username=$username" \
    -d "password=$password" \
    "$api_url/auth/login" 2>/dev/null)

if test $status -ne 0
    rm -f "$cookie_jar"
    echo "❌ qBT: API ERROR"
    exit 0
end

# Get transfer info (speeds)
set -l transfer_info (curl -s -b "$cookie_jar" "$api_url/transfer/info" 2>/dev/null)
if test $status -ne 0
    rm -f "$cookie_jar"
    echo "❌ qBT: NO DATA"
    exit 0
end

# Get torrents list
set -l torrents_info (curl -s -b "$cookie_jar" "$api_url/torrents/info" 2>/dev/null)
if test $status -ne 0
    rm -f "$cookie_jar"
    echo "❌ qBT: NO TORRENTS"
    exit 0
end

# Clean up
rm -f "$cookie_jar"

# Parse transfer info
set -l dl_speed (echo "$transfer_info" | jq -r '.dl_info_speed // 0' 2>/dev/null || echo "0")
set -l up_speed (echo "$transfer_info" | jq -r '.up_info_speed // 0' 2>/dev/null || echo "0")

# Count torrents by state
set -l total_torrents (echo "$torrents_info" | jq -r 'length' 2>/dev/null || echo "0")
set -l downloading (echo "$torrents_info" | jq -r '[.[] | select(.state == "downloading" or .state == "stalledDL" or .state == "metaDL")] | length' 2>/dev/null || echo "0")
set -l seeding (echo "$torrents_info" | jq -r '[.[] | select(.state == "uploading" or .state == "stalledUP")] | length' 2>/dev/null || echo "0")
set -l completed (echo "$torrents_info" | jq -r '[.[] | select(.state == "queuedUP" or .state == "uploading" or .state == "stalledUP")] | length' 2>/dev/null || echo "0")
set -l paused (echo "$torrents_info" | jq -r '[.[] | select(.state == "pausedDL" or .state == "pausedUP")] | length' 2>/dev/null || echo "0")

# Format speeds
set -l dl_formatted (format_bytes $dl_speed)
set -l up_formatted (format_bytes $up_speed)

# Create output based on activity
if test $total_torrents -eq 0
    echo "💀 qBT: IDLE"
else if test $downloading -gt 0
    echo "⬇️ $dl_formatted ⬆️ $up_formatted | $downloading/$total_torrents"
else if test $seeding -gt 0
    echo "🌱 $seeding seeding ⬆️ $up_formatted"
else
    echo "⏸️ $paused paused | $total_torrents total"
end 