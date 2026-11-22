. ~/trial/labs/lib.sh
sudo systemctl disable --now haproxy
runblk labs_c_12.sh | tee /tmp/l12a.out
expect "Lab 12 step 1: ansible.posix installed" /tmp/l12a.out 'ansible.posix.*(was installed successfully|is already installed)|Installing .ansible.posix'
cd ~/iac && cp $S/webserver.yml .
runblk labs_c_13.sh | tee /tmp/l12b.out
expect "Lab 12 step 2: syntax check" /tmp/l12b.out 'playbook: webserver.yml'
expect "Lab 12 step 2: first run changed, none failed" /tmp/l12b.out 'changed=[1-9].*failed=0'
expect "Lab 12 step 2: nginx answers" /tmp/l12b.out 'HTTP/1.1 200 OK'
ansible-playbook -i inventory.ini webserver.yml | tee /tmp/l12c.out
expect "Lab 12 step 3: second run changed=0" /tmp/l12c.out 'changed=0.*failed=0'
runblk labs_c_14.sh | tee /tmp/l12d.out
expect "Lab 12 step 4: repair run changed=1" /tmp/l12d.out 'changed=1.*failed=0'
systemctl is-active nginx | tee /tmp/l12e.out
expect "Lab 12 step 4: nginx running again" /tmp/l12e.out '^active$'
python3 $B/labs_c_15.py | tee /tmp/l12f.out
expect "Lab 12 step 5: energy saving" /tmp/l12f.out 'Saving: 52,560 kWh, PKR 2,628,000 per year'
