#!/usr/bin/env sh

# Start daemon if not running
if ! pgrep -x "awww-daemon" > /dev/null; then
    awww-daemon &
    sleep 0.5
fi

# Launch wallpaper script in background
"$HOME/.dotfiles/.local/share/bin/swwwallpaper.sh" &
