
# Configure the OpenStack Provider
provider "openstack" {
  user_name   = "$OS_USERNAME"
  tenant_name = "OS_PROJECT_NAME"
  password    = "$OS_PASSWORD"
  auth_url    = "$OS_AUTH_URL"
  region      = "$OS_REGION_NAME"
}

# Create a web server
resource "openstack_compute_instance_v2" "test-server" {
  name = "terraform-instance"
  image_id = "074263c3-fa70-41d7-88a6-ed83eca7dc03"
  flavor_id = "flavor-test"
  key_pair = "DEVOPS-ADMIN"
  security_groups = ["all-in-out"]  

  network {
    name = "ExternalNet-V7"
  }
}

