set -e fish_user_paths
set -U fish_user_paths $HOME/.local/bin $HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH $fish_user_paths

set fish_greeting
set TERM xterm-256color
set EDITOR emacsclient -c -a emacs
set VISUAL emacsclient -c -a emacs

function fish_user_key_bindings
    fish_vi_key_bindings
end

# aliases
alias ls 'exa -l --icons --color=always --group-directories-first'
alias la 'exa -a --icons --color=always --group-directories-first'
alias ll 'exa -al --icons --color=always --group-directories-first'
alias vim 'nvim'
alias vi 'vim'
alias rm 'rm -rf'
alias mv 'mv -i'

starship init fish | source
