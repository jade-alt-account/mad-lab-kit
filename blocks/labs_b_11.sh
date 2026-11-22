sudo pvcreate /dev/sdd
sudo vgcreate data_vg /dev/sdd
sudo lvcreate -n files_lv -L 400M data_vg
sudo mkfs.xfs /dev/data_vg/files_lv
sudo mkdir -p /files && sudo mount /dev/data_vg/files_lv /files
df -h /files
sudo lvextend -r -L +300M /dev/data_vg/files_lv
df -h /files
