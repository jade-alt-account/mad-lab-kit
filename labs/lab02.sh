. ~/trial/labs/lib.sh
cd ~ && cp $S/availability.py . && python3 availability.py | tee /tmp/l2a.out
expect "Lab 2 step 1: downtime table" /tmp/l2a.out '5,256.0 minutes'
expect "Lab 2 step 1: 52.6 minutes for 99.99%" /tmp/l2a.out '52.6 minutes'
expect "Lab 2 step 1: disk availability" /tmp/l2a.out '0.999989'
expect "Lab 2 step 1: serial/parallel" /tmp/l2a.out 'Parallel 0.99 and 0.99: 0.9999'
cat $B/labs_a_05.py >> availability.py && python3 availability.py | tee /tmp/l2b.out
expect "Lab 2 step 2: current design 97.91%" /tmp/l2b.out '97\.91'
runblk labs_a_06.sh | tee /tmp/l2c.out
expect "Lab 2 step 4: web1 answers" /tmp/l2c.out 'Served by web1'
expect "Lab 2 step 4: web2 answers" /tmp/l2c.out 'Served by web2'
runblk labs_a_07.sh | tee /tmp/l2d.out
expect "Lab 2 step 5: haproxy -c valid" /tmp/l2d.out 'Configuration file is valid'
systemctl is-active haproxy | tee -a /tmp/l2d.out
expect "Lab 2 step 5: haproxy running" /tmp/l2d.out '^active$'
sleep 5
runblk labs_a_08.sh | tee /tmp/l2e.out
n1=$(grep -c 'web1' /tmp/l2e.out); n2=$(grep -c 'web2' /tmp/l2e.out)
echo "web1=$n1 web2=$n2"
[ "$n1" -ge 3 ] && [ "$n2" -ge 3 ] && pass "Lab 2 step 6: round robin alternates ($n1/$n2)" || fail "Lab 2 step 6: round robin ($n1/$n2)"
runblk labs_a_09.sh | tee /tmp/l2f.out
tail -n 10 /tmp/l2f.out | grep -c 'web2' > /tmp/n
[ "$(cat /tmp/n)" -ge 4 ] && pass "Lab 2 step 7: after failure, web2 serves all requests" || fail "Lab 2 step 7: failover"
errs=$(grep -c 'Served by' /tmp/l2f.out); echo "answered requests: $errs of 15"
grep -q 'Served by web1' <(tail -n 8 /tmp/l2f.out) && fail "Lab 2 step 7: web1 still served after failure" || pass "Lab 2 step 7: web1 removed from rotation"
# restart web1 as the lab says, and check it returns
(cd ~/web1 && nohup python3 -m http.server 8001 > /dev/null 2>&1 &)
sleep 8
for i in $(seq 6); do curl -s localhost; done | tee /tmp/l2g.out
expect "Lab 2 step 7: web1 back in rotation" /tmp/l2g.out 'web1'
