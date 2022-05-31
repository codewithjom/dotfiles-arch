set -e fish_user_paths
set -U fish_user_paths $HOME/.local/bin $HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH $fish_user_paths

set fish_greeting ""
set fish_history ""
set TERM xterm-256color
set EDITOR emacsclient -c -a emacs
set VISUAL emacsclient -c -a emacs

function fish_user_key_bindings
    fish_vi_key_bindings
end

# aliases
alias ls 'exa -al --icons --color=always'
alias la 'exa -aG --icons --color=always --group-directories-first'
alias ll 'exa -alG --icons --color=always --group-directories-first'
alias vim 'nvim'
alias vi 'vim'
alias rm 'rm -rf'
alias mv 'mv -i'
alias cp 'cp -rf'
alias gs 'git status -s'
alias gc 'git commit '
alias ga 'git add '
alias gl 'git log --oneline'
alias gp 'git push'
alias gd 'git diff'
alias youtube-dl-music 'youtube-dl --extract-audio --audio-format mp3'
alias mpvid 'devour mpv'
alias sxiv 'devour sxiv'
alias zathura 'devour zathura'

if status --is-login
  if test -z "$DISPLAY" -a $XDG_VTNR = 1
    exec startx -- -keeptty 
  end
end

starship init fish | source
