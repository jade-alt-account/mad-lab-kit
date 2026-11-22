sudo dnf -y install net-snmp net-snmp-utils
sudo systemctl enable --now snmpd
snmpwalk -v2c -c public localhost system
snmpget -v2c -c public localhost SNMPv2-MIB::sysUpTime.0
