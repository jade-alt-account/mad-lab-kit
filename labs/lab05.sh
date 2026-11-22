. ~/trial/labs/lib.sh
sudo dnf -y -q install sysstat pciutils dmidecode > /dev/null
runblk labs_b_01.sh | tee /tmp/l5a.out
expect "Lab 5 step 1: processor listed" /tmp/l5a.out 'Model name'
expect "Lab 5 step 1: disks listed (ROTA column)" /tmp/l5a.out 'ROTA'
expect "Lab 5 step 1: firmware maker read" /tmp/l5a.out 'Manufacturer'
runblk labs_b_02.sh
sleep 3; vmstat 2 3 | tee /tmp/l5b.out; uptime | tee -a /tmp/l5b.out; pkill sha256sum
us=$(sed -n '5p' /tmp/l5b.out | awk '{print $13+$14}')
[ "${us:-0}" -ge 90 ] && pass "Lab 5 step 2: CPU saturated (us+sy=$us)" || fail "Lab 5 step 2: us+sy=$us"
free -m | tee /tmp/l5c0.out
(vmstat 2 12 > /tmp/l5c.out &)
runblk labs_b_03.sh > /tmp/l5c1.out 2>&1; sleep 2
cat /tmp/l5c.out /tmp/l5c1.out
grep -q Killed /tmp/l5c1.out && fail "Lab 5 step 3: program killed by OOM killer" || pass "Lab 5 step 3: 1,200 MB allocated without being killed"
swapped=$(awk 'NR>2 {s+=$7+$8} END {print s+0}' /tmp/l5c.out)
[ "$swapped" -gt 0 ] && pass "Lab 5 step 3: swap activity visible (si+so total $swapped)" || fail "Lab 5 step 3: no swap activity"
runblk labs_b_04.sh | tee /tmp/l5d.out
expect "Lab 5 step 5: boot mode reported" /tmp/l5d.out 'Booted with'
bash $S/perf_check.sh 2>&1 | tee /tmp/l5e.out
expect "Lab 5 step 4: perf_check.sh iostat output" /tmp/l5e.out '%util'
expect "Lab 5 step 4: perf_check.sh sar output" /tmp/l5e.out 'IFACE'
