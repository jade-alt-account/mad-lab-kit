. ~/trial/labs/lib.sh
sudo dnf -y -q install mdadm lvm2 fio > /dev/null
lsblk | tee /tmp/l7.out
# the lab says "answer y if asked"; the trial answers automatically
blk labs_b_09.sh | sed 's#^sudo mdadm --create#yes | sudo mdadm --create#' > /tmp/b9.sh
echo "----- block labs_b_09 (y answered) -----"; cat /tmp/b9.sh; bash /tmp/b9.sh 2>&1 | tee /tmp/l7a.out
expect "Lab 7 step 1: RAID 1 active" /tmp/l7a.out 'active raid1'
sleep 20; cat /proc/mdstat
runblk labs_b_10.sh | tee /tmp/l7b.out
expect "Lab 7 step 2: degraded [U_]" /tmp/l7b.out '\[U_\]|\[_U\]'
expect "Lab 7 step 2: data readable while degraded" /tmp/l7b.out 'important file'
sleep 40; cat /proc/mdstat | tee /tmp/l7c.out
expect "Lab 7 step 2: rebuilt [UU]" /tmp/l7c.out '\[UU\]'
runblk labs_b_11.sh | tee /tmp/l7d.out
grep '^/dev/mapper/data_vg-files_lv' /tmp/l7d.out | awk '{print $2}' > /tmp/l7sizes; sizes=$(tr '\n' ' ' < /tmp/l7sizes)
[ "$(wc -l < /tmp/l7sizes)" -eq 2 ] && [ "$(sort -u /tmp/l7sizes | wc -l)" -eq 2 ] && pass "Lab 7 step 3: LVM grew while mounted ($sizes)" || fail "Lab 7 step 3: LVM ($sizes)"
runblk labs_b_12.sh | tee /tmp/l7e.out
expect "Lab 7 step 4: fio reports IOPS" /tmp/l7e.out 'IOPS='
sudo rm -f /data/testfile
runblk labs_b_13.sh | tee /tmp/l7f.out
[ "$(grep -c ': OK' /tmp/l7f.out)" -eq 2 ] && pass "Lab 7 step 5: both archives verified" || fail "Lab 7 step 5"
ls -l /backup
runblk labs_b_14.sh | tee /tmp/l7g.out
expect "Lab 7 step 6: restore OK" /tmp/l7g.out 'Restore OK'
expect "Lab 7 step 6: incremental file restored" /tmp/l7g.out 'lab7-change.conf'
