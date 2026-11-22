sudo nmcli connection add type vlan con-name vlan10 ifname enp0s8.10 \
     dev enp0s8 id 10 ipv4.method manual ipv4.addresses 10.10.10.1/24
ip -d link show enp0s8.10
