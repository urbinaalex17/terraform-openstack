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

# Rules for the newly created security groups
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

resource "openstack_networking_secgroup_rule_v2" "secgroup_db_rule_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_db.id}"
}

# Create a web server
resource "openstack_compute_instance_v2" "instance_web" {
  name            = "terraform-instance-web"
  image_id        = "074263c3-fa70-41d7-88a6-ed83eca7dc03"
  flavor_id       = "0ff2705f-a6b5-4709-af68-7bac4e711d16"
  key_pair        = "DEVOPS-ADMIN"
  security_groups = ["${openstack_networking_secgroup_v2.secgroup_web.id}"]
  depends_on      = ["openstack_compute_instance_v2.instance_db"]

  network {
    name = "${var.network}"
  }

  provisioner "local-exec" {
    command = "echo ${openstack_compute_instance_v2.instance_web.network.0.fixed_ip_v4} >> ip_address.txt"
  }
}

# Create a database server
resource "openstack_compute_instance_v2" "instance_db" {
  name            = "terraform-instance-db"
  image_id        = "074263c3-fa70-41d7-88a6-ed83eca7dc03"
  flavor_id       = "0ff2705f-a6b5-4709-af68-7bac4e711d16"
  key_pair        = "DEVOPS-ADMIN"
  security_groups = ["${openstack_networking_secgroup_v2.secgroup_db.id}"]

  network {
    name = "${var.network}"
  }

  provisioner "local-exec" {
    command = "echo ${openstack_compute_instance_v2.instance_db.network.0.fixed_ip_v4} > ip_address.txt"
  }

}

# Outputs

output "instance_db_ip" {
  value = "${openstack_compute_instance_v2.instance_db.network.0.fixed_ip_v4}"
}


output "instance_web_ip" {
  value = "${openstack_compute_instance_v2.instance_web.network.0.fixed_ip_v4}"
}
