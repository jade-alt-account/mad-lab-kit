#!/bin/bash
# os_check.sh: inspect the operating system of a Linux server
# kernel version currently running
uname -r
# distribution name and version
cat /etc/os-release
# time since boot, users, and load averages
uptime
# kernel messages: hardware and driver errors and warnings
sudo dmesg --level=err,warn
