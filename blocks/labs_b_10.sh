sudo mdadm /dev/md0 --fail /dev/sdc
cat /proc/mdstat                    # [U_]: one disk missing
cat /data/important.txt             # the data is still there
sudo mdadm /dev/md0 --remove /dev/sdc
sudo mdadm /dev/md0 --add /dev/sdc
cat /proc/mdstat                    # recovery progress, then [UU]
