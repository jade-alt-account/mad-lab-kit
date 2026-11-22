. ~/trial/labs/lib.sh
runblk labs_a_04.sh | tee /tmp/l1.out
expect "Lab 1 Part F: OS name AlmaLinux" /tmp/l1.out 'NAME="AlmaLinux"'
expect "Lab 1 Part F: version 9.x" /tmp/l1.out 'VERSION="9\.'
expect "Lab 1 Part F: hypervisor detected" /tmp/l1.out '^(kvm|oracle|qemu)$'
expect "Lab 1 Part F: memory reported" /tmp/l1.out 'Mem:'
