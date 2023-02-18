#!/bin/bash

sudo apt update && sleep 5;

sudo apt install ansible;
sleep 3;
echo "ansible installed"

echo "running playbook to install and configure NGINX"
ansible-playbook -i inventory.yaml /home/nginx.yaml

echo "running playbook to sync the website files"
ansible-playbook -i inventory.yml /home/sync.yaml