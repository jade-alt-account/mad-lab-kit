. ~/trial/labs/lib.sh
sudo dnf -y -q install bind-utils traceroute tcpdump > /dev/null
sed "s/^traceroute -n 8.8.8.8/timeout 60 traceroute -n 8.8.8.8/" $S/net_check.sh > /tmp/nc.sh; bash /tmp/nc.sh 2>&1 | tee /tmp/l6a.out
expect "Lab 6 step 1: route table" /tmp/l6a.out 'default via'
expect "Lab 6 step 1: ping replies" /tmp/l6a.out 'bytes from 8.8.8.8|packets transmitted'
expect "Lab 6 step 1: DNS answer" /tmp/l6a.out '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
expect "Lab 6 step 1: listening ports" /tmp/l6a.out 'LISTEN'
runblk labs_b_05.sh | tee /tmp/l6b.out
expect "Lab 6 step 3: VLAN 10 interface" /tmp/l6b.out 'vlan protocol 802.1Q id 10'
sleep 3
blk labs_b_06.sh
(sudo timeout 25 tcpdump -e -n -c 4 -i eth1 vlan > /tmp/l6c.out 2>&1 &)
sleep 2; ping -c 4 10.10.10.2 > /dev/null 2>&1; sleep 4
cat /tmp/l6c.out
expect "Lab 6 step 4: tagged frames captured" /tmp/l6c.out 'vlan 10'
sudo nmcli connection delete vlan10
runblk labs_b_07.sh | tee /tmp/l6d.out
expect "Lab 6 step 5: public zone" /tmp/l6d.out 'public'
runblk labs_b_08.sh | tee /tmp/l6e.out
[ "$(grep -c success /tmp/l6e.out)" -eq 2 ] && pass "Lab 6 step 6: remove/add http" || fail "Lab 6 step 6"
bash $S/sec_check.sh 2>&1 | tee /tmp/l6f.out
expect "Lab 6 step 7: sec_check lists sshd" /tmp/l6f.out 'sshd'
expect "Lab 6 step 7: nftables rules printed" /tmp/l6f.out 'table inet firewalld'
