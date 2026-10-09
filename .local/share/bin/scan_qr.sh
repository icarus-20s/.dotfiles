#!/usr/bin/env bash

# Features:
#   • Select an area of the screen
#   • Decode QR codes
#   • Copy decoded content to the clipboard
#   • Automatically open URLs, email links, and telephone links
#   • Display desktop notifications
#
# Dependencies:
#   grim
#   slurp
#   zbar
#   wl-clipboard
#   libnotify

set -euo pipefail

readonly APP_NAME="QR Scanner"

TMP_FILE="$(mktemp --suffix=.png)"

cleanup() {
    rm -f "$TMP_FILE"
}

notify() {
    notify-send "$APP_NAME" "$1"
}

copy_to_clipboard() {
    printf "%s" "$1" | wl-copy
}

open_if_supported() {
    local content="$1"

    case "$content" in
        http://*|https://*)
            xdg-open "$content" >/dev/null 2>&1 &
            notify "Web link opened and copied to the clipboard."
            ;;

        mailto:*)
            xdg-open "$content" >/dev/null 2>&1 &
            notify "Email link copied to the clipboard."
            ;;

        tel:*)
            xdg-open "$content" >/dev/null 2>&1 &
            notify "Telephone link copied to the clipboard."
            ;;

        *)
            notify "QR code content copied to the clipboard."
            ;;
    esac
}

trap cleanup EXIT

# Capture selected region
GEOMETRY="$(slurp)" || {
    notify "Selection cancelled."
    exit 1
}

grim -g "$GEOMETRY" "$TMP_FILE"

# Decode QR code
QR_CONTENT="$(zbarimg --quiet --raw "$TMP_FILE" 2>/dev/null || true)"

if [[ -z "$QR_CONTENT" ]]; then
    notify "No QR code detected."
    exit 1
fi

copy_to_clipboard "$QR_CONTENT"
open_if_supported "$QR_CONTENT"

exit 0
