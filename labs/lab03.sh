. ~/trial/labs/lib.sh
sudo dnf -y -q install httpd-tools sysstat > /dev/null
runblk labs_a_10.sh | tee /tmp/l3a.out
expect "Lab 3 step 1: ab completed" /tmp/l3a.out 'Requests per second'
expect "Lab 3 step 1: no failed requests" /tmp/l3a.out 'Failed requests: +0'
for c in 100 200; do ab -n 2000 -c $c http://127.0.0.1/ 2>&1 | grep -E 'Requests per second|Failed requests|95%' | tee /tmp/l3b_$c.out; done
expect "Lab 3 step 2: -c 100 completed" /tmp/l3b_100.out 'Requests per second'
expect "Lab 3 step 2: -c 200 completed" /tmp/l3b_200.out 'Requests per second'
(ab -n 20000 -c 100 http://127.0.0.1/ > /dev/null 2>&1 &)
sleep 3; vmstat 2 4 | tee /tmp/l3c.out; pkill ab
us=$(tail -n 1 /tmp/l3c.out | awk '{print $13+$14}'); echo "us+sy=$us"
[ "$us" -ge 60 ] && pass "Lab 3 step 3: processor is the bottleneck (us+sy=$us)" || fail "Lab 3 step 3: us+sy only $us"
mkdir -p ~/l3 && cd ~/l3
# the handbook's script asks for a password interactively; the trial supplies one
sed 's/-salt -in/-salt -pass pass:labtest -in/; s/-pbkdf2 -in marks.enc/-pbkdf2 -pass pass:labtest -in marks.enc/' $S/crypto_demo.sh > c.sh
echo "----- crypto_demo.sh (password supplied) -----"; cat c.sh
bash c.sh | tee /tmp/l3d.out
[ "$(awk '{print $1}' /tmp/l3d.out | sort -u | wc -l)" -eq 1 ] && pass "Lab 3 step 5: hashes before and after match" || fail "Lab 3 step 5: hashes differ"
grep -q 'Final marks' marks.enc && fail "Lab 3 step 5: marks.enc readable" || pass "Lab 3 step 5: marks.enc unreadable"
sed -i 's/78/79/' marks.txt; sha256sum marks.txt | tee -a /tmp/l3d.out
[ "$(awk '{print $1}' /tmp/l3d.out | sort -u | wc -l)" -eq 2 ] && pass "Lab 3 step 6: changed file gives new hash" || fail "Lab 3 step 6"
openssl enc -d -aes-256-cbc -pbkdf2 -in marks.enc -out x.txt -pass pass:wrong 2>&1 | tee /tmp/l3e.out
expect "Lab 3 step 7: wrong password gives bad decrypt" /tmp/l3e.out 'bad decrypt'
