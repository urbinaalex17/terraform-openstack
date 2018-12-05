install-loadbalancer-iap
=======================

Description
-----------

Ansible playbook that install IAP Load Balancer in Load Balancer Node

Requirements
------------

This playbook has been tested on Ansible 2.4.2.0. It requires Red Hat Enterprise Linux 7 or CentOS 7.

* RHEL 7+ / CentOS 7
* Allow root permisition

Playbook Variables
------------------

*General variables*

| Name              | Default Value              | Description                     |
|-------------------|----------------------------|---------------------------------|
| pathiap           | /var/iap                   | Path of iap                     |
| pathinstall       | /services/LoadBalancer     | Path of LoadBalancer in install |

*General variables*

| Name              | Default Value              | Description                     |
|-------------------|----------------------------|---------------------------------|
| target            | localhost                  | servers where run playbook      |

Usage
-----

Go to ansible path
`cd ${HOME}/continuousintegration/services/LoadBalancer/ansible`

and run the play book
`sudo ansible-playbook main.yml --extra-vars "target=localhost pathrepo=${HOME}/continuousintegration" -vvv`

