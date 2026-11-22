#!/bin/bash
# net_check.sh: test the network layer by layer from a Linux computer
# layers 1-2: interfaces and whether links are up
ip -br link
# layer 2: IP-to-MAC mappings learned by ARP
ip neigh
# layer 3: routing table and default gateway
ip route
# layer 3: can we reach a host on the Internet?
ping -c 4 8.8.8.8
# layer 3: the routers along the path
traceroute -n 8.8.8.8
# layer 4: TCP ports this computer is listening on
ss -tln
# layer 7: does name resolution (DNS) work?
dig www.example.com +short
