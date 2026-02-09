source ~/.zshrc_config
source ~/.zshrc_util
source /usr/share/fzf/key-bindings.zsh

HISTSIZE=10000      # Number of commands to remember in the current session
SAVEHIST=10000     # Number of commands to save in the history file
HISTFILE=~/.zsh_history  # Path to the history file
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt ignoreeof 	# Remove ctrl+d to exit

export EDITOR=nano
export DF="/home/ayush/.dotfiles"
export CF="/home/ayush/.config"
export NSXIV_OPTS="/home/ayush/Misc/wallpaper/"

stty -ixon

typeset -U path PATH	
mcd() {
    mkdir -p "$1" && cd "$1"
}

op() {
    xdg-open "$1" &>/dev/null &
}

off() {
    if [[ "$1" == "off" ]]; then
        shutdown -c
    else
        shutdown -h "$1"
    fi
}

fs() {
  find . -path "./.cache" -prune -o -regex ".*$1.*"
}

fd() {
  find . -path "./.cache" -prune -o -type d -regex ".*$1.*"
}

iv() {
 nsxiv "$@" -r "$NSXIV_OPTS" -o
}

ex() {
 local dir="${1:-$pwd}" 
 nautilus "$dir" > /dev/null 2>&1 & disown
}
__head() {
  head -n "${1:-10}"
}

__tail() {
  tail -n "${1:-10}"
}

alias ..="cd .."
alias ...="cd .. && cd .."

alias del="gio trash"
alias venv="virtualenv"
alias activate="source ./.venv/bin/activate"
alias uvenv="uv venv"
alias ur="uv run"
alias studymode='sudo /usr/local/bin/study_mode.sh' 
alias -g F='| fzf'
alias -g G='| grep -i'
alias -g H='| __head'
alias -g T='| __tail'
alias -g W='| wc -l'
alias -g C='| wl-copy'
alias -g rp='realpath'
alias -g P='| bat --pager "less -RF"'
alias p='bat --pager "less -RF"'
alias key='showkey -a'
alias l='eza -lh --icons=auto'
alias ls='eza -1 --icons=auto'
alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
alias ld='eza -lhD --icons=auto'
alias lt='eza --icons=auto --tree'
alias sl='du -hsc * | sort -hr'
alias grep='grep --color=auto'
alias md='mkdir'

alias hkey='sudo libinput debug-events'
	
alias -g jc='journalctl'
alias -g jcu='journalctl --user'
alias -g sys='systemctl'
alias -g  sysu='systemctl --user'
alias -g stat='systemctl status'
alias -g statu='systemctl --user status'

alias hc='hyprctl'
alias dockers='docker stop $(docker ps -q) && sudo systemctl stop docker.socket docker'

alias iphone-mount='mkdir -p ~/mnt/iPhone && ifuse ~/mnt/iPhone'
alias iphone-umount='fusermount -u ~/mnt/iPhone'
alias free-my-iphone='
iphone-mount && \
echo "Starting backup from iPhone → ~/Pictures/iPhone ..." && \
mkdir -p ~/Pictures/iPhone && \
rsync -avh --progress --ignore-existing ~/mnt/iPhone/DCIM/ ~/Pictures/iPhone/ && \
echo "Backup complete. Deleting files from iPhone..." && \
find ~/mnt/iPhone/DCIM -type f \( \
  -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.heic" -o \
  -iname "*.mov" -o -iname "*.mp4" \
\) -exec rm {} \; && \
echo "Files deleted from iPhone. Remember to empty Recently Deleted on iPhone to free space!" && \
iphone-umount
'

alias c='clear'
alias nf='fastfetch'
alias ff='fastfetch'
alias n='nano'
alias sn='sudo nano'
alias cd='z'
alias cdi='zi'
alias b='z -'
alias pms='sudo pacman'
alias e='nano ~/.zshrc'
alias ec='nano ~/.zshrc_config'
alias eu='nano ~/.zshrc_util'
alias reload='source ~/.zshrc'
alias r='source ~/.zshrc'
alias rr='clear && source ~/.zshrc'
alias dep='pactree -r'
aurhelper='yay'
alias un='$aurhelper -Rns'
alias up='$aurhelper -Syu'
alias sync='$aurhelper -Syy'
alias upi='$aurhelper -Qu | sort'
alias in='$aurhelper -S'
alias ins='$aurhelper -Qi'
alias pl='$aurhelper -Qs' 
alias pa='$aurhelper -Ss'
alias pf='$aurhelper -F'
alias pc='$aurhelper -Sc --noconfirm' 
#alias pkg='$aurhelper -Qi | awk '\''/^Name/ {name=$3} /^Install Date/ {print $4, $5, $6, $7, $8, $9, name}'\'' | sort -k3,3r -k2,2n -k1,1M -k7,7 -k6,6'
pkg() {
    local date_filter=""
    local month_filter=""

    while getopts "d:m:" opt; do
        case $opt in
            d) date_filter="$OPTARG" ;;
            m) month_filter="$OPTARG" ;;
            *) return 1 ;;
        esac
    done

    local base_command="$aurhelper -Qi | awk '/^Name/ {name=\$3} /^Install Date/ {print \$4, \$5, \$6, \$7, \$8, \$9, name}'"

    if [[ -n $date_filter ]]; then
        base_command="$base_command | awk -v date=\"$date_filter\" '\$2 ~ date'"
    fi

    if [[ -n $month_filter ]]; then
        base_command="$base_command | awk -v month=\"$month_filter\" '\$3 ~ month'"
    fi

    result=$(eval "$base_command")

    if [[ -n $result ]]; then
        echo "$result" | sort -k3,3r -k2,2n -k1,1M -k6,6 -k5,5
    else
        echo "No matching packages found."
    fi
}

function hb {
    if [ $# -eq 0 ]; then
        echo "No file path or text specified."
        return
    fi

    uri="http://bin.christitus.com/documents"
    
    if [ -f "$1" ]; then
        content="$(cat "$1")"
    else
        content="$1"
    fi

    response=$(curl -s -X POST -d "$content" "$uri")
    if [ $? -eq 0 ]; then
        hasteKey=$(echo "$response" | jq -r '.key')
        echo "http://bin.christitus.com/$hasteKey" | wl-copy
        echo "http://bin.christitus.com/$hasteKey"
    else
        echo "Failed to upload the document."
    fi
}

type starship_zle-keymap-select >/dev/null || \
  {
    eval "$(/usr/bin/starship init zsh)"
  }

eval "$(zoxide init zsh)"

# pokemon-colorscripts --no-title -r 1,2,3,4,5,6,7

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /home/ayush/.dart-cli-completion/zsh-config.zsh ]] && . /home/ayush/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]



export ANDROID_HOME=/home/ayush/Android/Sdk
export ANDROID_SDK_ROOT=/home/ayush/Android/Sdk

export PATH=$ANDROID_HOME/emulator:$PATH
export PATH=$ANDROID_HOME/platform-tools:$PATH
export PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$PATH
export PATH=$ANDROID_HOME/tools:$PATH
export PATH=$ANDROID_HOME/tools/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"

