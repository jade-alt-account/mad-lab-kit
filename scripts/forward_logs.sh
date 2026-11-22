#!/bin/bash
# forward_logs.sh: send serious log messages to a central log server
echo '*.crit @@logs.example.com:514' | sudo tee /etc/rsyslog.d/90-forward.conf
sudo systemctl restart rsyslog
logger -p user.crit "TEST: central logging check from $(hostname)"
