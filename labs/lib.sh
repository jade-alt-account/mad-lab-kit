# lib.sh: helpers for the lab trial (runs inside the AlmaLinux VM)
T=~/trial; B=$T/blocks; S=$T/scripts
# Differences between the trial VM (QEMU/KVM, cloud image) and the students' VirtualBox VM:
#   host-only NIC enp0s8 -> eth1; extra SATA disks sdb/sdc/sdd -> virtio vdb/vdc/vdd;
#   sudo needs no password here, so Ansible's -K (ask for the sudo password) is dropped.
SUBST='s/enp0s8/eth1/g; s#/dev/sdb#/dev/vdb#g; s#/dev/sdc#/dev/vdc#g; s#/dev/sdd#/dev/vdd#g; s/ -K$//; s/ -K / /'
pass() { echo "PASS: $*"; }
fail() { echo "FAIL: $*"; }
# blk NAME: print the block with the trial substitutions applied
blk() { sed "$SUBST" "$B/$1"; }
# runblk NAME: run a handbook block exactly (after substitutions), echoing it first
runblk() { echo "----- block $1 -----"; blk "$1"; echo "----- output -----"; blk "$1" | bash 2>&1; }
# expect DESC FILE REGEX: pass if FILE contains REGEX
expect() { if grep -Eq -- "$3" "$2"; then pass "$1"; else fail "$1 (missing: $3)"; fi; }
