# operating system
cat /etc/os-release | head -2
# compute: processor
lscpu | grep -E "Model name|^CPU\(s\)"
# compute: memory
free -h
# storage
lsblk
# networking
ip -br addr
# virtualization: which hypervisor runs this VM
systemd-detect-virt
