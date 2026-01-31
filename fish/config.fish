if status is-interactive
    # Commands to run in interactive sessions can go here
end

# set global npm path
set -gx PATH (npm config get prefix)/bin $PATH

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/mcduck/.lmstudio/bin
# End of LM Studio CLI section

# eza (better)
alias ls "eza --color=always --long --git --icons=always --no-user --no-permissions --hyperlink --header"

# thefuck :)
thefuck --alias | source
thefuck --alias fk | source

zoxide init fish | source

alias python python3

# editor environment to neovim
set -Ux EDITOR nvim

# my y (yazi) follow with path to open the specific folder
function y
    set tmp (mktemp -t yazi-cwd.XXXXXX)
    yazi $argv --cwd-file="$tmp"

    if test -f "$tmp"
        set cwd (cat "$tmp")
        if test -n "$cwd"; and test "$cwd" != "$PWD"
            cd "$cwd"
        end
    end

    rm -f "$tmp"
end

set -gx NVM_DIR $HOME/.nvm

source $HOME/.cargo/env.fish
set -gx PATH $HOME/.cargo/bin $PATH

set -gx PNPM_HOME $HOME/Library/pnpm
if not contains $PNPM_HOME $PATH
    set -gx PATH $PNPM_HOME $PATH
end

set -gx PATH $HOME/.local/bin $PATH

