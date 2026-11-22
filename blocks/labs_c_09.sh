sudo tee /etc/rsyslog.d/10-receive.conf > /dev/null <<'EOF'
module(load="imudp")
input(type="imudp" port="514")
EOF
sudo systemctl restart rsyslog
logger -n 127.0.0.1 -P 514 -d -p user.crit \
     "TEST: message received over the network"
sudo grep "TEST: message received" /var/log/messages
