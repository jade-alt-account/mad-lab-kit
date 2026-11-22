#!/bin/bash
# perf_check.sh: find a server's bottleneck (iostat and sar: sysstat package)
nproc                 # number of processor threads available
vmstat 2 5            # CPU, memory, swap and I/O wait every 2 seconds
iostat -x 2 3         # per-disk use: %util near 100 means the disk is saturated
sar -n DEV 2 3        # network traffic per interface
