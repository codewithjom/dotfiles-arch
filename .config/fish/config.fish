set -e fish_user_paths
set -U fish_user_paths $HOME/.local/bin $HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH $fish_user_paths

set fish_greeting ""
set fish_history ""
set -gx TERM xterm-256color
# Set EDITOR/VISUAL as emacs
# set EDITOR emacsclient -c -a emacs
# set VISUAL emacsclient -c -a emacs
set -gx EDITOR nvim
set -gx VISUAL nvim

# theme
set -g theme_color_scheme terminal-dark
set -g fish_prompt_pwd_dir_lenght 1
set -g theme_display_user yes 
set -g theme_hide_hostname no
set -g theme_hostname always

function fish_user_key_bindings
    fish_vi_key_bindings
end

# aliases
alias ls 'exa -l --color=always --group-directories-first'
alias la 'exa -aG --color=always --group-directories-first'
alias ll 'exa -alG --color=always --group-directories-first'
alias vim 'nvim'
alias em '/usr/bin/emacs -nw'
# alias rm 'rm -rf'
alias rm 'trash'
alias mv 'mv -i'
alias cp 'cp -rf'
alias gs 'git status -s'
alias gc 'git commit '
alias ga 'git add '
alias gl 'git log --oneline'
alias gp 'git push'
alias gd 'git diff'
alias youtube-dl-music 'youtube-dl --extract-audio --audio-format mp3'
alias mpvid 'mpv'
alias sxiv 'sxiv'
alias zathura 'zathura'
# alias clear 'clear && colorscript -e 35'
alias checkupdates 'checkupdates | less'
alias . 'tmux new-session -s 1'
# alias how-old-am-i "sudo dumpe2fs $(mount | grep 'on \/ ' | awk '{print $1}') | grep 'Filesystem created:'"
alias xampp-start 'sudo xampp startapache; sudo xampp startmysql'

if status --is-login
  if test -z "$DISPLAY" -a $XDG_VTNR = 1
    exec startx -- -keeptty 
  end
end

# Package name: shell-color-scripts
# colorscript -r

# fisher install IlanCosman/tide@v5 (Fish prompt)
# Remove comment below if not using custom prompt (fisher/tide)
starship init fish | source
