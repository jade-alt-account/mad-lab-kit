#!/bin/bash
# storage_check.sh: identify local and network storage on a Linux server
# disks, partitions, file systems and mount points
lsblk -f
# SCSI devices, including SAN LUNs
sudo lsscsi
# find iSCSI targets
sudo iscsiadm -m discovery -t sendtargets -p 192.168.10.50
# mounted NFS and SMB (CIFS) shares
findmnt -t nfs,nfs4,cifs
