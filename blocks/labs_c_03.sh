sudo dnf check-update
sudo dnf updateinfo list --security
sudo dnf -y upgrade --security
sudo dnf needs-restarting -r
