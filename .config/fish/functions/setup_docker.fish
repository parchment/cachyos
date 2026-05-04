function setup_docker --description "Idempotent Docker setup"
    sudo systemctl enable --now docker
    groups | grep -q docker || sudo usermod -aG docker $USER
    systemctl is-active docker \
        && echo "docker: ok" \
        || echo "docker: FAIL"
end
