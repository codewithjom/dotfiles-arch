export TERM="xterm-256color"
export HISTCONTROL=ignoredups:erasedups
export EDITOR="nvim"
export VISUAL="nvim"
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH:$HOME/.local/bin:$HOME/.config/composer/vendor/bin"

unset HISTFILE

set -o vi
bind -m vi-command 'Control-l: clear-screen'
bind -m vi-insert 'Control-l: clear-screen'

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

bind "set completion-ignore-case on"

alias ..='cd ..'
alias .='tmux new-session -s 1'
alias ls='exa --color=always --group-directories-first --icons'
alias la='exa -aG --color=always --group-directories-first --icons'
alias ll='exa -l --color=always --group-directories-first --icons'
# alias vim='nvim'
alias vim='lvim'
alias em='/usr/bin/emacs -nw'
# alias rm='rm -rf'
alias rm='trash'
alias mv='mv -i'
alias cp='cp -rf'
alias gs='git status -s'
alias gc='git commit '
alias ga='git add '
alias gl='git log --oneline'
alias gp='git push'
alias gd='git diff'
alias youtube-dl-music='youtube-dl --extract-audio --audio-format mp3'
# alias mpvid='devour mpv'
# alias sxiv='devour sxiv'
# alias zathura='devour zathura'
alias checkupdates='checkupdates | less'

# eval "$(starship init bash)"
