function toggle_desktop
    set stash_ws "special:_desktop_stash"
    set current_ws (hyprctl activeworkspace -j | jq '.id')
    set stashed (hyprctl clients -j | jq -r "[.[] | select(.workspace.name == \"special:_desktop_stash\")] | length")

    if test "$stashed" -gt 0
        # Restore: move all stashed windows back to current workspace
        hyprctl clients -j | jq -r ".[] | select(.workspace.name == \"special:_desktop_stash\") | .address" \
            | while read addr
                hyprctl dispatch movetoworkspacesilent "$current_ws,address:$addr"
            end
    else
        # Stash: move all windows on current workspace to hidden special workspace
        hyprctl clients -j | jq -r ".[] | select(.workspace.id == $current_ws) | .address" \
            | while read addr
                hyprctl dispatch movetoworkspacesilent "$stash_ws,address:$addr"
            end
    end
end
