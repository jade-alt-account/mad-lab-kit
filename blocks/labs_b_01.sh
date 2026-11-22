lscpu | grep -E "Model name|Socket|Core|Thread|^CPU\(s\)|L3"
free -h
lsblk -d -o NAME,SIZE,ROTA,MODEL
lspci | grep -iE "ethernet|sata|storage|vga"
sudo dmidecode -t system | grep -E "Manufacturer|Product|Serial"
