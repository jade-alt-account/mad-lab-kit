#!/bin/bash
# vm_admin.sh: manage KVM virtual machines with virsh
# all VMs, running and shut off
virsh list --all
# a VM's state, vCPUs and memory
virsh dominfo web01
# which physical CPUs its vCPUs use
virsh vcpuinfo web01
# snapshot before a change
virsh snapshot-create-as --domain db01 --name pre_upgrade
# ask the guest OS to shut down cleanly
virsh shutdown web01
