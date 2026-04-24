#!/bin/env bash

CURRENT_SSID=$(nmcli -t -f active,ssid dev wifi | awk -F: '$1=="yes" {print $2}')
BEST_NETWORK=$(nmcli -t -f SSID,RATE,SIGNAL dev wifi | sort -t: -k2,2nr -k3,3nr | head -n 1 | cut -d: -f1)

if [[ "$BEST_NETWORK" != "$CURRENT_SSID" && -n "$BEST_NETWORK" ]]; then
    nmcli device disconnect "$CURRENT_SSID"
    nmcli device wifi connect "$BEST_NETWORK"
    notify-send "Switched to Wi-Fi: $BEST_NETWORK"
fi
