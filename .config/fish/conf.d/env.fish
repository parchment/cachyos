# Editor + terminal
set -gx EDITOR helix
set -gx TERMINAL ghostty

# Package managers
fish_add_path $HOME/.cargo/bin
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
fish_add_path $PNPM_HOME

# Keyring SSH agent
set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/keyring/ssh"

# fzf
set -gx ATUIN_NOBIND true
if type -q fzf
    set -gx FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border"
    if type -q fd
        set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude .git"
    end
end
