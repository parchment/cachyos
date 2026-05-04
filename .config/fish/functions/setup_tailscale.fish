function setup_tailscale --description "Idempotent Tailscale setup"
    sudo systemctl enable --now tailscaled
    systemctl is-active tailscaled \
        && echo "tailscale: ok" \
        || echo "tailscale: FAIL"
    sudo tailscale up --ssh
end
