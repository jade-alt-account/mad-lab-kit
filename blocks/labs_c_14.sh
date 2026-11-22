sudo systemctl stop nginx
ansible-playbook -i inventory.ini webserver.yml -K
