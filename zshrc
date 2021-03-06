# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="yyyy-mm-dd"
ZSH_CUSTOM="$HOME/projects/dotfiles/oh-my-zsh-custom"
plugins=(git colored-man-pages auto-notify command-not-found fzf sudo poetry)
ZSH_DISABLE_COMPFIX="true"

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:$HOME/gems/bin:$HOME/.config/composer/vendor/bin:$HOME/.local/bin"
export GEM_HOME="$HOME/gems"
export EDITOR="vi"
export GIT_EDITOR="vi"
export VISUAL="vi"
export TERM=xterm-256color
export XZ_DEFAULTS=--threads=0
export PYTHONBREAKPOINT="pudb.set_trace"

source $ZSH/oh-my-zsh.sh

export AUTO_NOTIFY_THRESHOLD=120
AUTO_NOTIFY_IGNORE+=("docker" "tail" "docker-compose" "vi" "ctop" "sudo" "git" "glg" "grip" "zsh" "fg" "bg", "bc", "nvtop", "glances")

fpath=("$HOME/projects/dotfiles/zfunctions" $fpath)
autoload -U promptinit; promptinit
prompt pure
prompt_newline='%666v'
PROMPT=" $PROMPT"

alias ls='ls --color=tty -N'
alias psgrep='ps aux | grep -v grep | grep -i'
alias a=ll
alias ac='clear && ll'
alias yellow='lynx -stdin -dump'
alias weather='curl wttr\.in'
alias moon='curl wttr\.in/Moon'
alias bc='bc -l'
alias glg='git lg'
alias vim='nvim'
alias vims='vim -S .session.vim'
alias gvims='gvim -S .session.vim'
alias open='xdg-open'
alias cat='bat --paging=never'
alias dd='dd status=progress'
alias free='free -h'
alias df='df -h'
alias du='du -h'
alias vnstat='vnstat -i enp5s0'

function cs() {
    cd $1 && clear && ll
}

export FZF_DEFAULT_COMMAND='fd --hidden --no-ignore --type file --follow --exclude .git --exclude Games --exclude .wine --exclude .vim --exclude .steam --exclude .snapshots --exclude .cache'

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND --type directory --type symlink"
export FZF_CTRL_T_OPTS="
--preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200'
--bind '?:toggle-preview'
"

export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --type directory"
export FZF_ALT_C_OPTS="
--preview 'tree -C {} | head -200'
--bind '?:toggle-preview'
"

export FZF_DEFAULT_OPTS="
--layout=reverse
--height=40%
--multi
--color='hl:148,hl+:154,pointer:032,marker:010,bg+:237,gutter:008'
--prompt='∼ ' --pointer='▶' --marker='✓'
"

function countdown(){
    date1=$((`date +%s` + $1));
    while [ "$date1" -ge `date +%s` ]; do
        echo -ne "$(date -u --date @$(($date1 - `date +%s`)) +%H:%M:%S)\r";
        sleep 0.1
    done
}

function stopwatch(){
    date1=`date +%s`;
    while true; do
        echo -ne "$(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)\r";
        sleep 0.1
    done
}

function timer(){
    if [[ $1 ]]; then
        countdown $1
    else
        stopwatch
    fi
}

[ -f /home/thiago/.unlock_keys ] && source /home/thiago/.unlock_keys

typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]='fg=white'
[ -f  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source /usr/share/nvm/init-nvm.sh

[ -f /home/thiago/.local_keys ] && source /home/thiago/.local_keys

# Invoke completion
source $ZSH_CUSTOM/scripts/invoke/invoke_completion

autoload -Uz compinit
zstyle ':completion:*' menu select
fpath+=~/.zfunc
