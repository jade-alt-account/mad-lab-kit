. ~/trial/labs/lib.sh
runblk labs_c_07.sh
sleep 2; curl -sk -o /dev/null -w '%{http_code}\n' https://localhost:9090/ | tee /tmp/l11a.out
expect "Lab 11 step 1: Cockpit answers on 9090" /tmp/l11a.out '^200$'
runblk labs_c_08.sh | tee /tmp/l11b.out
expect "Lab 11 step 2: sysDescr" /tmp/l11b.out 'sysDescr.0 = STRING: Linux'
expect "Lab 11 step 2: sysUpTime" /tmp/l11b.out 'Timeticks'
runblk labs_c_09.sh | tee /tmp/l11c.out
expect "Lab 11 step 3: network log message received" /tmp/l11c.out 'TEST: message received over the network'
mkdir -p ~/sla && cd ~/sla && cp $B/labs_c_10.txt incidents.csv && cp $S/sla_report.py .
python3 sla_report.py | tee /tmp/l11d.out
diff <(sed 's/ *$//' /tmp/l11d.out) <(sed 's/ *$//' $B/labs_c_11.txt) && pass "Lab 11 step 5: SLA report matches the handbook exactly" || fail "Lab 11 step 5: SLA report differs"
bash $S/forward_logs.sh 2>&1; systemctl is-active rsyslog | tee /tmp/l11e.out
expect "Lab 11: forward_logs.sh leaves rsyslog running" /tmp/l11e.out '^active$'
sudo rm -f /etc/rsyslog.d/90-forward.conf; sudo systemctl restart rsyslog
