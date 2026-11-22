sudo tcpdump -e -n -c 4 -i enp0s8 vlan        # window 1
ping -c 4 10.10.10.2                            # window 2
