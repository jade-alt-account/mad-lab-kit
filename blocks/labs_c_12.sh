sudo dnf -y install ansible-core
ansible-galaxy collection install ansible.posix
mkdir -p ~/iac && cd ~/iac
printf "[webservers]\nlocalhost ansible_connection=local\n" > inventory.ini
