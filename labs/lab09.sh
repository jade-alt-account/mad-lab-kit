. ~/trial/labs/lib.sh
bash $S/os_check.sh 2>&1 | tee /tmp/l9a.out
expect "Lab 9 step 1: os_check kernel" /tmp/l9a.out '^5\.14'
runblk labs_c_01.sh | tee /tmp/l9b.out
expect "Lab 9 step 1: root is xfs" /tmp/l9b.out 'xfs'
runblk labs_c_02.sh > /tmp/l9c.out 2>&1 < /dev/null; cat /tmp/l9c.out
n0=$(awk '$2=="0" && $4=="sha256sum" {print int($3)}' /tmp/l9c.out); n19=$(awk '$2=="19" && $4=="sha256sum" {print int($3)}' /tmp/l9c.out)
echo "nice 0: ${n0}%  nice 19: ${n19}%"
[ "${n0:-0}" -ge 80 ] && [ "${n19:-100}" -le 10 ] && pass "Lab 9 step 2: scheduler favours nice 0 (${n0}% vs ${n19}%)" || fail "Lab 9 step 2: nice 0 ${n0}% vs nice 19 ${n19}%"
runblk labs_c_03.sh | tee /tmp/l9d.out
expect "Lab 9 step 3: needs-restarting ran" /tmp/l9d.out 'Reboot is required|No core libraries or services have been updated|Reboot should not be necessary'
grep -q "No such command\|Unknown argument" /tmp/l9d.out && fail "Lab 9 step 3: needs-restarting missing" || pass "Lab 9 step 3: needs-restarting available"
runblk labs_c_04.sh | tee /tmp/l9e.out
expect "Lab 9 step 4: SELinux Enforcing" /tmp/l9e.out '^Enforcing$'
expect "Lab 9 step 4: only root has UID 0" /tmp/l9e.out '^root$'
expect "Lab 9 step 4: sshd -T works" /tmp/l9e.out 'permitrootlogin'
echo "PasswordAuthentication no" | sudo tee /etc/ssh/sshd_config.d/00-hardening.conf
sudo sshd -t && sudo systemctl reload sshd && sudo sshd -T | grep -i '^passwordauthentication' | tee /tmp/l9f.out
expect "Lab 9 step 5: hardening applied" /tmp/l9f.out 'passwordauthentication no'
