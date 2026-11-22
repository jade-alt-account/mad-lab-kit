sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb /dev/sdc
cat /proc/mdstat
sudo mkfs.xfs /dev/md0
sudo mkdir -p /data && sudo mount /dev/md0 /data
echo "important file" | sudo tee /data/important.txt
