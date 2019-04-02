# Based on miloshadzic's theme

ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg[green]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg[green]%})%{$reset_color%}%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg_bold[yellow]%}⚡%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_VIRTUALENV_PREFIX="%{$fg[black]%}["
ZSH_THEME_VIRTUALENV_SUFFIX="]%{$reset_color%} "

local ret_status="%(?:%{$fg_bold[green]%}✔ :%{$fg_bold[red]%}✘ %s)"

function shebang(){
    if [ $(print -P "%#") = '#' ]; then
        echo "red"
    else
        echo "cyan"
    fi
}

# PROMPT='${ret_status}$(virtualenv_prompt_info)$(git_prompt_info)%{$fg_no_bold[cyan]%}%~%{$reset_color%}%{$fg[red]%}%{$reset_color%}%{$fg[$(shebang)]%} %#%{$reset_color%} '
# PROMPT='${ret_status}$(virtualenv_prompt_info)%{$fg[green]%}%m $(git_prompt_info)%{$fg_no_bold[cyan]%}%~%{$reset_color%}%{$fg[red]%}%{$reset_color%}%{$fg[$(shebang)]%} %#%{$reset_color%} '
PROMPT='${ret_status}$(virtualenv_prompt_info)$(git_prompt_info)%{$fg_no_bold[cyan]%}%~%{$reset_color%}%{$fg[red]%}%{$reset_color%}%{$fg[$(shebang)]%} %#%{$reset_color%} '
