#!/usr/bin/env sh

SECONDARY="HDMI-A-1"
STATE_FILE="/tmp/hypr_gamemode"

# ─────────────────────────────
# ENABLE GAMEMODE
# ─────────────────────────────
if [ ! -f "$STATE_FILE" ]; then

    # Disable second monitor
    hyprctl keyword monitor "$SECONDARY,disable"

    # Disable animations (faster input feel)
    hyprctl keyword animations:enabled 0

    # Optional: kill Waybar (clean FPS boost)
    pkill waybar

    # mark state
    touch "$STATE_FILE"

    notify-send "Game Mode" "Enabled 🎮"

# ─────────────────────────────
# DISABLE GAMEMODE
# ─────────────────────────────
else

    # Restore monitor
    hyprctl keyword monitor "$SECONDARY,preferred,auto,1"

    # Re-enable animations
    hyprctl keyword animations:enabled 1

    # Restart Waybar
    waybar &

    # remove state
    rm "$STATE_FILE"

    notify-send "Game Mode" "Disabled 🖥️"
fi