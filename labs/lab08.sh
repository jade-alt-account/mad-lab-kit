. ~/trial/labs/lib.sh
runblk labs_b_16.sh 2>&1 | tee /tmp/l8a.out
expect "Lab 8 step 4: timing printed" /tmp/l8a.out 'real'
runblk labs_b_18.sh | tee /tmp/l8b.out
expect "Lab 8 step 5: container answers 200 OK" /tmp/l8b.out 'HTTP/1.1 200 OK'
expect "Lab 8 step 5: podman ps shows web" /tmp/l8b.out 'nginx:stable'
runblk labs_b_19.sh | tee /tmp/l8c.out
expect "Lab 8 step 6: stats printed" /tmp/l8c.out 'MEM USAGE'
expect "Lab 8 step 6: 64 MB limit shown" /tmp/l8c.out '/ 6[0-9]\.[0-9]+MB|/ 64MB|67.11MB'
expect "Lab 8 step 6: start timed" /tmp/l8c.out 'real'
podman stop web > /dev/null 2>&1; podman rm web > /dev/null 2>&1
