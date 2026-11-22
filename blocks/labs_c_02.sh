taskset -c 0 sha256sum /dev/zero &
taskset -c 0 nice -n 19 sha256sum /dev/zero &
sleep 10
ps -o pid,ni,%cpu,comm -C sha256sum
pkill sha256sum
