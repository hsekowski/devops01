#!/usr/bin/env bash

cd src/vagrant/ && vagrant destroy -f && vagrant up && vagrant ssh -c "cat /dev/zero | ssh-keygen -m PEM -t rsa -b 4096 -q -N '' && az login && cd /vagrant/terraform/ && terraform init && terraform destroy -auto-approve && terraform apply -auto-approve && cd /vagrant/ansible/ && ansible-inventory -i myazure_rm.yml --graph && ansible-playbook -i ./myazure_rm.yml nginx_on_docker.yml --limit=tag_software_nginx_on_docker && ansible-playbook -i ./myazure_rm.yml haproxy.yml --limit=tag_software_haproxy && cd /vagrant/terraform/ && terraform output"
