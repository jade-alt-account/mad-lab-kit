#!/bin/bash
# health_check.sh: a quick performance and availability check on a Linux server
# how long the server has run, and its load averages
uptime
# free disk space: a full disk is a common cause of outages
df -h
# memory and swap in use
free -h
# processor, memory, swap and I/O every 2 seconds, 5 times
vmstat 2 5
# the processes using the most processor time now
top -b -n 1 | head -n 15
