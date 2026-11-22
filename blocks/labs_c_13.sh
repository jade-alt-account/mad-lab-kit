ansible-playbook -i inventory.ini webserver.yml --syntax-check
ansible-playbook -i inventory.ini webserver.yml -K
curl -I http://localhost
