# Suppress greeting
set fish_greeting

# zoxide — must be in config.fish (not conf.d) to load after PATH is set
zoxide init fish | source

# Fisher — install if missing, then update plugins from fish_plugins
if not functions -q fisher
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish \
        | source && fisher install jorgebucaran/fisher
end
fisher update
