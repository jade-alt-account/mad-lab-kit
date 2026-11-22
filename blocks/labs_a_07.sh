sudo dnf -y install haproxy
sudo cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.orig
sudo tee /etc/haproxy/haproxy.cfg > /dev/null <<'EOF'
defaults
    mode http
    timeout connect 5s
    timeout client 30s
    timeout server 30s

frontend web
    bind *:80
    default_backend app

backend app
    balance roundrobin
    option httpchk GET /
    server web1 127.0.0.1:8001 check inter 2s fall 2 rise 2
    server web2 127.0.0.1:8002 check inter 2s fall 2 rise 2
EOF
sudo setsebool -P haproxy_connect_any on
sudo haproxy -c -f /etc/haproxy/haproxy.cfg
sudo systemctl enable --now haproxy
sudo firewall-cmd --permanent --add-service=http && sudo firewall-cmd --reload
