# SELinux mode: should be Enforcing
getenforce
# allowed services and ports
sudo firewall-cmd --list-all
# accounts with root's user ID (only root)
awk -F: '$3 == 0 {print $1}' /etc/passwd
# users allowed to use sudo
getent group wheel
sudo sshd -T | grep -iE "^(permitrootlogin|passwordauthentication)"
systemctl list-unit-files --type=service --state=enabled
