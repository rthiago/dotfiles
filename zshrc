# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="yyyy-mm-dd"
ZSH_CUSTOM="$HOME/projects/dotfiles/oh-my-zsh-custom"
plugins=(git colored-man-pages auto-notify command-not-found fzf sudo)
ZSH_DISABLE_COMPFIX="true"

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:$HOME/gems/bin:$HOME/.config/composer/vendor/bin"
export GEM_HOME="$HOME/gems"
export EDITOR="vi"
export GIT_EDITOR="vi"
export VISUAL="vi"

source $ZSH/oh-my-zsh.sh

export AUTO_NOTIFY_THRESHOLD=120
AUTO_NOTIFY_IGNORE+=("docker" "tail" "docker-compose" "vi" "ctop" "sudo" "git" "glg" "grip" "zsh" "fg" "bg", "bc", "nvtop")

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
alias yaourt='yaourt --noconfirm'
alias glg='git lg'
alias vims='vim -S .session.vim'
alias gvims='gvim -S .session.vim'

function cs() {
  cd $1 && clear && ll
}

export FZF_DEFAULT_COMMAND='rg --hidden --no-ignore --files'
export FZF_DEFAULT_OPTS='--height 40% --reverse'

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
