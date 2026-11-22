#!/bin/bash
# hw_check.sh: check a Linux server's hardware resources
free -h              # memory and swap in use
lscpu                # processor model, sockets, cores and threads
lsblk                # disks and partitions, with their mount points
sudo ipmitool sensor # temperatures, fan speeds and voltages from the BMC
