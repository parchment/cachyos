#!/usr/bin/env bash
set -euo pipefail

# Set fish as default shell — idempotent
grep -q "^/usr/bin/fish$" /etc/shells || echo "/usr/bin/fish" | sudo tee -a /etc/shells
[ "$SHELL" = "/usr/bin/fish" ] || chsh -s /usr/bin/fish

# Fisher + plugins — reads fish_plugins manifest, idempotent
fish -c '
    if not functions -q fisher
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish \
            | source && fisher install jorgebucaran/fisher
    end
    fisher update
'

echo "--- Layer 4 verification ---"
fish --version
fish -c 'type atuin'
fish -c 'type zoxide'
fish -c 'functions -q _hydro_pwd && echo "hydro: ok" || echo "hydro: FAIL"'
echo "--- Layer 4 complete ---"
