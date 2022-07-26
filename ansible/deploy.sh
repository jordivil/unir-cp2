#!/bin/bash
terraform -chdir=../terraform apply infraestructura-cp2
echo "Tres minutos de espera a Azure"
sleep 3m
ansible-playbook playbook.yml -i hosts
