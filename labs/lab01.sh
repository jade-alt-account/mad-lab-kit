. ~/trial/labs/lib.sh
runblk labs_a_04.sh | tee /tmp/l1.out
expect "Lab 1 Part F: OS is AlmaLinux 9" /tmp/l1.out 'AlmaLinux 9'
expect "Lab 1 Part F: hypervisor detected" /tmp/l1.out '^(kvm|oracle|qemu)$'
expect "Lab 1 Part F: memory reported" /tmp/l1.out 'Mem:'
