. ~/trial/labs/lib.sh
# The trial VM is a cloud image: its cloud-init package stops sshd-keygen from recreating host keys.
# A VM installed from the ISO (as in Lab 1) has no cloud-init, so remove that drop-in to match it.
sudo rm -f /usr/lib/systemd/system/sshd-keygen@.service.d/disable-sshd-keygen-if-cloud-init-active.conf \
           /etc/systemd/system/sshd-keygen@.service.d/disable-sshd-keygen-if-cloud-init-active.conf
sudo systemctl daemon-reload
cat /etc/machine-id > ~/old-machine-id; ls /etc/ssh/ssh_host_*_key.pub | xargs sha256sum > ~/old-hostkeys
# the trial reboots the VM from outside instead of powering it off
blk labs_c_05.sh | grep -v '^sudo poweroff' > /tmp/b5.sh
echo "----- block labs_c_05 (without poweroff) -----"; cat /tmp/b5.sh; bash /tmp/b5.sh 2>&1 | tail -n 5
[ ! -s /etc/machine-id ] && pass "Lab 10 step 3: machine-id emptied" || fail "Lab 10 step 3: machine-id not empty"
ls /etc/ssh/ssh_host_* 2>/dev/null | grep -q . && fail "Lab 10 step 3: host keys remain" || pass "Lab 10 step 3: host keys removed"
