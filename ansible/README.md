# Ansible scripts

Ansible playbook to configure Waggle Dance

## Requirements
* Ansible 2.3+

## How to Run?
1. Clone this repo
2. Make sure you have run `terraform apply` which generates required files at `ansible/` location:
    * `{ENVIRONMENT}-hosts`
4. Run `ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i {HOSTS_FILE} --private-key=PATH-TO-PRIVATE-KEY-FILE {PLAYBOOK.yml}`
