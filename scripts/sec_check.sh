#!/bin/bash
# sec_check.sh: inspect a Linux server's network exposure
# listening TCP and UDP ports, with the program using each
sudo ss -tulpn
# firewall rules and their packet counters (older systems)
sudo iptables -L -n -v
# the same on systems using nftables (most current Linux)
sudo nft list ruleset
# where traffic leaves the server
ip route show
