# Configure the OpenStack Provider
provider "openstack" {
  user_name   = ""
  tenant_name = ""
  password    = ""
  auth_url    = "https://172.16.1.11:5000/v3"
  region      = ""
  cacert_file = ""
  insecure    = true
}

# Create sec grups for web server and database server
resource "openstack_networking_secgroup_v2" "secgroup_web" {
  name        = "secgroup-web"
  description = "Web Server security group"
}

resource "openstack_networking_secgroup_v2" "secgroup_db" {
  name        = "secgroup-db"
  description = "Data Base security group"
}

resource "openstack_networking_secgroup_v2" "secgroup_lb" {
  name        = "secgroup-ln"
  description = "Load Balancer security group"
}

# Rules for the newly created security groups
# Web Server's group rules
resource "openstack_networking_secgroup_rule_v2" "secgroup_web_rule_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_web.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_web_rule_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_web.id}"
}

# DB's group rules
resource "openstack_networking_secgroup_rule_v2" "secgroup_db_rule_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_db.id}"
}

# Load Balancer's group rules
resource "openstack_networking_secgroup_rule_v2" "secgroup_lb_rule_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_lb.id}"
}


resource "openstack_networking_secgroup_rule_v2" "secgroup_lb_rule_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_lb.id}"
}

# Create a 10G volume
resource "openstack_blockstorage_volume_v2" "vol_01" {
  name = "terraform-volume-01"
  size = 10
}
# Create a web server
resource "openstack_compute_instance_v2" "instance_web" {
  name            = "terraform-instance-web"
  image_id        = "074263c3-fa70-41d7-88a6-ed83eca7dc03"
  flavor_id       = "0ff2705f-a6b5-4709-af68-7bac4e711d16"
  key_pair        = "${var.key-pair-openstack}"
  security_groups = ["${openstack_networking_secgroup_v2.secgroup_web.id}"]
  power_state     = "active"
  network {
    name = "${var.network}"
  }

  provisioner "local-exec" {
    command = <<EOD
    cat <<EOF > "ansible/openstack_hosts"
[webservers]
${openstack_compute_instance_v2.instance_web.network.0.fixed_ip_v4}
[dbservers]
${openstack_compute_instance_v2.instance_db.network.0.fixed_ip_v4}
[loadbalancer]
${openstack_compute_instance_v2.instance_lb.network.0.fixed_ip_v4}
[all:children]
dbservers
webservers

EOF
    EOD
  }
}

resource "null_resource" "ansible_playbook_01" {
  depends_on = ["openstack_compute_volume_attach_v2.attached_instance_web"]
  provisioner "local-exec" {
    command = "sleep 20 && ansible-playbook -i ansible/openstack_hosts -u ${var.remote-user} --private-key=${var.key-pair-path} ansible/playbooks/connection-wait.yml -e target=all"
  }
}

resource "null_resource" "ansible_playbook_02" {
  depends_on = ["null_resource.ansible_playbook_01"]
  provisioner "local-exec" {
    command = "ansible-playbook -i ansible/openstack_hosts -u ${var.remote-user} --private-key=${var.key-pair-path} ansible/playbooks/pre-requisites-web.yml -e 'target=webservers device=${openstack_compute_volume_attach_v2.attached_instance_web.device}'"
  }
}  

resource "null_resource" "ansible_playbook_03" {
  depends_on = ["null_resource.ansible_playbook_02"]
  provisioner "local-exec" {
    command = "ansible-playbook -i ansible/openstack_hosts -u ${var.remote-user} --private-key=${var.key-pair-path} ansible/playbooks/infra-runtime-environment-jboss.yml -e target=webservers"
  }
}

# Attach the volume 
resource "openstack_compute_volume_attach_v2" "attached_instance_web" {
  instance_id = "${openstack_compute_instance_v2.instance_web.id}"
  volume_id = "${openstack_blockstorage_volume_v2.vol_01.id}"
}

# Create a database server
resource "openstack_compute_instance_v2" "instance_db" {
  name            = "terraform-instance-db"
  image_id        = "074263c3-fa70-41d7-88a6-ed83eca7dc03"
  flavor_id       = "0ff2705f-a6b5-4709-af68-7bac4e711d16"
  key_pair        = "${var.key-pair-openstack}"
  security_groups = ["${openstack_networking_secgroup_v2.secgroup_db.id}"]

  network {
    name = "${var.network}"
  }

}


# Create a load balancer server
resource "openstack_compute_instance_v2" "instance_lb" {
  name            = "terraform-instance-lb"
  image_id        = "074263c3-fa70-41d7-88a6-ed83eca7dc03"
  flavor_id       = "0ff2705f-a6b5-4709-af68-7bac4e711d16"
  key_pair        = "${var.key-pair-openstack}"
  security_groups = ["${openstack_networking_secgroup_v2.secgroup_lb.id}"]

  network {
    name = "${var.network}"
  }

}


# Outputs

output "instance_db_ip" {
  value = "${openstack_compute_instance_v2.instance_db.network.0.fixed_ip_v4}"
}

output "instance_web_ip" {
  value = "${openstack_compute_instance_v2.instance_web.network.0.fixed_ip_v4}"
}

output "instance_web_lb" {
  value = "${openstack_compute_instance_v2.instance_lb.network.0.fixed_ip_v4}"
}
