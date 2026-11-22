#!/bin/bash
# run.sh: boot an AlmaLinux 9 VM with QEMU/KVM on the GitHub runner and run the ITI lab trial
set -u
cd "$(dirname "$0")"
mkdir -p results work
IMG_URL=https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2
cd work
ssh-keygen -q -t ed25519 -N "" -f vmkey
curl -sSL -o alma.qcow2 "$IMG_URL"
qemu-img resize -q alma.qcow2 20G
for d in 1 2 3; do qemu-img create -q -f qcow2 d$d.qcow2 1G; done
cat > user-data <<UD
#cloud-config
hostname: srv042
fqdn: srv042.lab.local
users:
  - name: ali
    groups: wheel
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - $(cat vmkey.pub)
UD
echo "instance-id: iti-trial" > meta-data
cloud-localds seed.iso user-data meta-data
sudo sysctl -q -w net.ipv4.ping_group_range='0 2147483647'
# 1 CPU and 1.5 GB: the smallest VM the Lab Manual recommends
qemu-system-x86_64 -enable-kvm -cpu host -m 1536 -smp 1 \
  -drive file=alma.qcow2,if=virtio -cdrom seed.iso \
  -drive file=d1.qcow2,if=virtio -drive file=d2.qcow2,if=virtio -drive file=d3.qcow2,if=virtio \
  -netdev user,id=n0,hostfwd=tcp::2222-:22,hostfwd=tcp::8080-:80,hostfwd=tcp::9090-:9090 \
  -device virtio-net-pci,netdev=n0 -netdev user,id=n1 -device virtio-net-pci,netdev=n1 \
  -display none -serial file:../results/serial.log -daemonize
SSHO="-i vmkey -p 2222 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=5 -o ServerAliveInterval=30"
vm() { ssh $SSHO ali@127.0.0.1 "$@"; }
waitvm() { for i in $(seq 120); do vm true 2>/dev/null && return 0; sleep 5; done; return 1; }
waitvm || { echo "VM did not come up"; exit 1; }
vm 'sudo cloud-init status --wait' > /dev/null 2>&1
tar -C .. -cf - blocks scripts labs | vm 'mkdir -p ~/trial && tar -C ~/trial -xf -'
# Make the cloud image match a minimal ISO installation: firewalld, rsyslog and swap,
# and the second network card connected (the host-only adapter in VirtualBox).
vm 'bash -s' > ../results/setup.log 2>&1 <<'SETUP'
sudo dnf -y -q install firewalld rsyslog nano tar
sudo systemctl enable --now firewalld rsyslog
sudo fallocate -l 1536M /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile
sudo nmcli device connect eth1 || true
echo "== Lab 1 step 9 block (update and addresses) =="
bash -c "$(sed 's/enp0s8/eth1/g' ~/trial/blocks/labs_a_02.sh)"
echo "== VM =="; cat /etc/almalinux-release; uname -r; nproc; free -h; swapon --show; lsblk; getenforce
SETUP
run() { echo "=== $1 ==="; timeout 2400 ssh $SSHO ali@127.0.0.1 "bash ~/trial/labs/$1.sh" > ../results/$1.log 2>&1; echo "exit $?" >> ../results/$1.log; }
for l in lab01 lab02; do run $l; done
# From the host (the student's laptop browser in the lab), through the forwarded port
curl -s -m 5 http://localhost:8080/ | grep -q 'Served by' && echo "PASS: Lab 2: page reachable from outside the VM" >> ../results/host.log || echo "FAIL: Lab 2: page not reachable from outside the VM" >> ../results/host.log
for l in lab03 lab04 lab05 lab06 lab07 lab08 lab09 lab11; do run $l; done
code=$(curl -sk -o /dev/null -w '%{http_code}' -m 10 https://localhost:9090/)
[ "$code" = 200 ] && echo "PASS: Lab 11: Cockpit reachable from outside the VM" >> ../results/host.log || echo "FAIL: Lab 11: Cockpit from outside ($code)" >> ../results/host.log
run lab12
run lab10
vm 'sudo reboot' > /dev/null 2>&1; sleep 20
waitvm && run lab10b || echo "FAIL: Lab 10: VM did not come back after reboot" >> ../results/host.log
cd ../results
grep -h '^PASS\|^FAIL' host.log lab*.log > summary.txt
echo "PASS $(grep -c ^PASS summary.txt)  FAIL $(grep -c ^FAIL summary.txt)" | tee -a summary.txt
