. ~/trial/labs/lib.sh
runblk labs_c_06.sh | tee /tmp/l10.out
new=$(cat /etc/machine-id); old=$(cat ~/old-machine-id); echo "old=$old new=$new"
[ -n "$new" ] && [ "$new" != "$old" ] && pass "Lab 10 step 5: new machine ID after first boot" || fail "Lab 10 step 5: machine ID"
ls /etc/ssh/ssh_host_*_key.pub | xargs sha256sum > /tmp/newkeys
[ -s /tmp/newkeys ] && ! cmp -s <(awk '{print $1}' /tmp/newkeys) <(awk '{print $1}' ~/old-hostkeys) && pass "Lab 10 step 5: new SSH host keys" || fail "Lab 10 step 5: host keys"
hostname | tee -a /tmp/l10.out
expect "Lab 10 step 5: host name set" /tmp/l10.out 'desk01'
