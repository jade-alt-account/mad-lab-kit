# the image should be fully patched
sudo dnf -y upgrade
sudo hostnamectl set-hostname localhost.localdomain
# SSH host keys: recreated at next boot
sudo rm -f /etc/ssh/ssh_host_*
# unique machine ID: recreated at next boot
sudo truncate -s 0 /etc/machine-id
sudo poweroff
