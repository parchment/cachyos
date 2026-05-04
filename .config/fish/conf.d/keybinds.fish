# Atuin — shell history search bound to Ctrl+R and Up arrow
atuin init fish | source
bind \cr _atuin_search
bind -M insert \cr _atuin_search
bind \e\[A _atuin_search
bind -M insert \e\[A _atuin_search
