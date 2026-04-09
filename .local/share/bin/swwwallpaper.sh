#!/usr/bin/env sh

# Lock instance
lockFile="/tmp/hyde$(id -u)$(basename "$0").lock"
[ -e "${lockFile}" ] && echo "An instance of the script is already running..." && exit 1
touch "${lockFile}"
trap 'rm -f ${lockFile}' EXIT

# Functions
Wall_Cache() {
    ln -fs "${wallList[setIndex]}" "${wallSet}"
    ln -fs "${wallList[setIndex]}" "${wallCur}"
    "${scrDir}/awwallcache.sh" -w "${wallList[setIndex]}" &> /dev/null
    "${scrDir}/awwallbash.sh" "${wallList[setIndex]}" &
    ln -fs "${thmbDir}/${wallHash[setIndex]}.sqre" "${wallSqr}"
    ln -fs "${thmbDir}/${wallHash[setIndex]}.thmb" "${wallTmb}"
    ln -fs "${thmbDir}/${wallHash[setIndex]}.blur" "${wallBlr}"
    ln -fs "${thmbDir}/${wallHash[setIndex]}.quad" "${wallQad}"
    ln -fs "${dcolDir}/${wallHash[setIndex]}.dcol" "${wallDcl}"
}

Wall_Change() {
    curWall="$(set_hash "${wallSet}")"
    for i in "${!wallHash[@]}"; do
        if [ "${curWall}" = "${wallHash[i]}" ]; then
            if [ "${1}" = "n" ]; then
                setIndex=$(( (i + 1) % ${#wallList[@]} ))
            elif [ "${1}" = "p" ]; then
                setIndex=$(( i - 1 ))
            fi
            break
        fi
    done
    Wall_Cache
}

# Variables
scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/globalcontrol.sh"
wallSet="${hydeThemeDir}/wall.set"
wallCur="${cacheDir}/wall.set"
wallSqr="${cacheDir}/wall.sqre"
wallTmb="${cacheDir}/wall.thmb"
wallBlr="${cacheDir}/wall.blur"
wallQad="${cacheDir}/wall.quad"
wallDcl="${cacheDir}/wall.dcol"

# Check walls
setIndex=0
[ ! -d "${hydeThemeDir}" ] && echo "ERROR: \"${hydeThemeDir}\" does not exist" && exit 1
wallPathArray=("${hydeThemeDir}")
wallPathArray+=("${wallAddCustomPath[@]}")
get_hashmap "${wallPathArray[@]}"
[ ! -e "${wallSet}" ] && ln -fs "${wallList[setIndex]}" "${wallSet}"

# Options
while getopts "nps:" option; do
    case $option in
        n ) xtrans="grow"; Wall_Change n ;;
        p ) xtrans="outer"; Wall_Change p ;;
        s ) [ ! -z "${OPTARG}" ] && [ -f "${OPTARG}" ] && get_hashmap "${OPTARG}"; Wall_Cache ;;
        * ) echo "Usage: $(basename "$0") -[n|p|s <file>]"; exit 1 ;;
    esac
done

# Start daemon if not running
if ! pgrep -x "awww-daemon" > /dev/null; then
    awww-daemon &
    sleep 0.5
fi

# Defaults
[ -z "${xtrans}" ] && xtrans="grow"
[ -z "${wallFramerate}" ] && wallFramerate=60
[ -z "${wallTransDuration}" ] && wallTransDuration=0.4

# Apply wallpaper on all monitors (Wayland)
echo ":: applying wall :: ${wallSet}"
for mon in $(hyprctl monitors -j | jq -r '.[].name'); do
    awww img "$(readlink -f "${wallSet}")" &
    sleep 0.2
done
wait
