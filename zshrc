# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""
# CASE_SENSITIVE="true"
# ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="yyyy-mm-dd"
ZSH_CUSTOM="$HOME/projects/dotfiles/oh-my-zsh-custom"
plugins=(git colored-man-pages)

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:$HOME/gems/bin:$HOME/.config/composer/vendor/bin"
export GEM_HOME="$HOME/gems"
export EDITOR="vi"
export GIT_EDITOR="vi"
export VISUAL="vi"

source $ZSH/oh-my-zsh.sh

fpath=("$HOME/projects/dotfiles/zfunctions" $fpath)
autoload -U promptinit; promptinit
prompt pure
prompt_newline='%666v'
PROMPT=" $PROMPT"

alias ls='ls --color=tty -N'
alias psgrep='ps aux | grep -v grep | grep -i'
alias a=ll
alias ac='clear && ll'
# alias cat='pygmentize -g'
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

[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--height 40% --reverse'

if [ -x /usr/bin/pkgfile ]; then
  command_not_found_handler() {
    local pkgs cmd="$1"

    pkgs=(${(f)"$(pkgfile -b -v -- "$cmd" 2>/dev/null)"})
    if [[ -n "$pkgs" ]]; then
      printf '%s may be found in the following packages:\n' "$cmd"
      printf '  %s\n' $pkgs[@]
    else
      printf '%s not found :(\n' "$cmd"
    fi

    return 127
  }
fi

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

# source /usr/share/nvm/init-nvm.sh
