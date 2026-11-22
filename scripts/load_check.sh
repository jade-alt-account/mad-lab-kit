#!/bin/bash
# load_check.sh: watch processor and network load on a Linux node
# load averages for 1, 5 and 15 minutes, and running/total processes
cat /proc/loadavg
# one line per logical CPU: core, socket, online state
lscpu -e
# use of each CPU, three samples two seconds apart (sysstat package)
mpstat -P ALL 2 3
# traffic on each network interface (sysstat package)
sar -n DEV 2 3
