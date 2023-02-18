#!/bin/bash

sudo apt update -y && sleep 5;

sudo apt install -y ansible;
sleep 3;
echo "ansible installed"

echo "running playbook to install and configure NGINX"
ansible-playbook -i /home/ansible/inventory.yaml /home/ansible/nginx.yaml

echo "running playbook to sync the website files"
ansible-playbook -i /home/ansible/inventory.yml /home/ansible/sync.yaml