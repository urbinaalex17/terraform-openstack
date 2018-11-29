install-jboss-eap
================

Description
-----------
Advanced Ansible role that install Red Hat JBoss Enterprise Application Platform (EAP) 7 instances.

Requirements
------------
This role has been tested on Ansible 2.4.2.0. It requires Red Hat Enterprise Linux 7 or CentOS 7.

* RHEL 7+ / CentOS 7
* Port Offset (`jboss_eap_instance_port_offset`)
* Environment Name of your choosing (`environment_name`,`jboss_eap_instance_name`)
* Timezone (`timezone`)
* List of path to WARs to deploy(`jboss_eap_war_files`)
* Interfaces to bind to ( Defaults to `jboss_eap_bind_address: "192.168.1.151"`, `jboss_eap_management_bind_address: "192.168.1.151"` (localhost only, (0.0.0.0 *DOES NOT WORK*))}}/)

*The following files will be copied to the destination machine in the following default path:*

  /files/jboss-eap-7.1.0.zip
  /files/jdk-8u152-linux-x64.rpm

| Ansible Variable(s)  | Default Value       | Description          |
|-------------------|---------------------|----------------------|
| `jboss_eap_golden_image_dir` | `/mnt/nfs/ansible/redhat/rh_jboss_golden_images/` | Directory of zip |
| `java_jdk_rpm` | `/mnt/nfs/ansible/jdk-8u152-linux-x64.rpm`` | Java JDK RPM |
| `jboss_eap_golden_image_name` | `jboss-eap-7.1.0` | Base name of zip file (without .zip extension) |


Role Variables
--------------
*General variables*

| Name              | Default Value       | Description          |
|-------------------|---------------------|----------------------|
| `timezone` | `Europe/Madrid` | Self Explanatory |
| `jboss_eap_golden_image_dir` | `/mnt/nfs/ansible/redhat/rh_jboss_golden_images` | Directory location of golden image zip |
| `jboss_eap_golden_image_subdir` | `jboss-eap-7.1.0` | Directory name of root directory inside zip |
| `jboss_eap_golden_image_name` | `jboss-eap-7.1.0` | The name of the zip file (excluding .zip)|
| `jboss_serverid` | `jbosspc-{{ jboss_eap_instance_name }}` |  Serverid |
| `jboss_eap_base_dir` | `/jboss` |  Base Directory for EAP Installation |
| `jboss_eap_instance_name` | `default` |  Name of the separate running Red Hat JBoss EAP instance |
| `jboss_eap_instance_standalone_file` | `standalone-full-ha.xml` | Name of the used standalone XML file |
| `jboss_eap_instance_service_name` | `jboss_{{ jboss_eap_instance_name }}` | JBoss EAP service name|
| jboss_app_users: user: jbossiap, group: jbossiap, user_home: "/home/jbossiap" | | System user configuration |
| jboss_management_users: - user: test , password: test | JBoss Management users [Set this in vault_files] |
| `jboss_eap_bind_address` | `"127.0.0.1"` | JBoss EAP IP Address to bind to (0.0.0.0 *DOES NOT WORK* |
| `jboss_eap_bind_ip_address_management` | `"0.0.0.0"` | JBoss EAP IP Address to bind to for management |
| `jvm_xm` | `512` | alue for the xms and xmx (both are set equal) |
| `jboss_eap_max_post_size` | `157286400` | Max POST Size|
| `jboss_mod_cluster_proxies` | `proxyjbossweb{{ jboss_eap_instance_name }}` | Mod_cluster proxies name |
| `jboss_outbound_socket_name` | `proxyjbossweb{{ jboss_eap_instance_name }}` | Outbound socket name |
| jboss_management_users:  - user: admin1    password: "adminpassword"  - user: admin2    password: "adminpass" | | List of administrator user accounts and passwords to configure |
| `java_jdk_rpm` | /mnt/nfs/ansible/jdk-8u152-linux-x64.rpm` | Used java version: Java 8 JDK.  |
| `jboss_java_home` | `/usr/lib/jvm/java-1.8.0-openjdk` | Default JAVA_HOME |
| `JAVA_OPTS` |  `-Djava.net.preferIPv4Stack=true -Xms512m -Xmx512m -XX:PermSize=526m -Dsun.rmi.dgc.client.gcInterval=3600000 -Dsun.rmi.dgc.server.gcInterval=3600000 -Dorg.jboss.resolver.warning=true -server -Dgw.server.mode=dev -Djboss.as.management.blocking.timeout=1200` | Java params |
| `jboss_eap_jgroups_multicast_address` | `230.0.0.4` | Default Address  |
| `jboss_eap_modcluster_multicast_address` | `224.0.1.105` | Default Address |
| `user_limits` | `See Defaults/main.yml` | Default User Limits |
| `jboss_eap_war_files` | `[ /path/to/war.war, /path/to/war2/war ]` | (Empty )List with paths to War files to be installed |
| `jboss_datasource` | `See Defaults/main.yml` | Datasource  |
| `jboss_jndi_name` | `java:jboss/datasources/pcDataSource` | JNDI Name |
| `jboss_jdbc_driver` | `See Defaults/main.yml` | JDBC Configuration |
| `jboss_log_name` | `"jboss{{ jboss_eap_instance_name }}-server.log" | Server log filename|
| `jboss_eap_force_remove` | `False` | Change this to true to remove the current installation for the environment|

*Ports Variables*

| Name              | Default Value       | Description          |
|-------------------|---------------------|----------------------|
| `jboss_eap_instance_port_offset` | `0` | Port offset for the JBoss EAP instance  |
| `jboss_eap_instance_management_http_port` | `9990` | Default Management Port |
| `jboss_eap_instance_management_https_port` | `9993` | Default Management SSL Port |
| `jboss_eap_instance_ajp_port` | `8009` | AJP Port |
| `jboss_eap_instance_http_port` | `8080` | HTTP Port |
| `jboss_eap_instance_https_port` | `8443` | HTTPS Port |
| `jboss_eap_instance_iiop_port` | `3528` | IIOP Port |
| `jboss_eap_instance_iiop__ssl_port` | `3529` | IIOP SSL Port |
| `jboss_eap_jgroups_mping_port` | `7600` | JGroups Ping port |
| `jboss_eap_jgroups_tcp_port` | `7600` | Port |
| `jboss_eap_jgroups_tcp_fd_port` | `57600` | Port |
| `jboss_eap_jgroups_udp_port` | `55200` | Port |
| `jboss_eap_jgroups_udp_fd_port` | `54200` | Port |
| `jboss_eap_txn_recovery_environment_port` | `4712` | Port |
| `jboss_eap_txn_status_manager_port` | `4713` | Port |
| `jboss_eap_mail_smtp_port` | `25` | Port |
| `jboss_eap_jgroups_multicast_tcp_port` | `45700` | Port |
| `jboss_eap_jgroups_multicast_udp_port` | `45688` | Port |
| `jboss_eap_modcluster_multicast_port` | `23364` | Port |
| `jboss_eap_outbound_proxy_port` | `6666` | Port |


Example Playbook
----------------

Here is a playbook creating three JBoss EAP instances on every host in "jboss-group":

```yaml
  - hosts: "jboss-group"
    vars:
      environment_name: "Dev3"
      jboss_eap_instance_name: "{{ environment_name }}"
      jboss_eap_instance_port_offset: 10
      JAVA_OPTS: "-Djava.net.preferIPv4Stack=true \
      -Xms524m -Xmx524m -XX:PermSize=526m -Dsun.rmi.dgc.client.gcInterval=3600000 \
      -Dsun.rmi.dgc.server.gcInterval=3600000 -Dorg.jboss.resolver.warning=true -server \
      -Dgw.server.mode=dev -Djboss.as.management.blocking.timeout=1200"
      jboss_eap_war_files:
      - /mnt/nfs/ansible/billing-hub/ojdbc7.jar
      jboss_eap_bind_address: "{{ ansible_ens160.ipv4.address }}"
      jboss_eap_management_bind_address: "{{ ansible_ens160.ipv4.address }}"
    vars_files:
    - vault_files/jboss_management.yml
    roles:
    - {
        role: "install-jboss-eap"
      }
```

vault_files/jboss_management.yml should contain the following structure:
```yaml
jboss_management_users:
- user: admin1
  password: "adminpassword"
- user: admin2
  password: "adminpass"
```

Tags
----
##### Stopping EAP Service
```bash
ansible-playbook deploy-jboss-eap.yml -e 'target=rh72'  -t stop_eap
```
##### (Re)starting EAP Service
```bash
ansible-playbook deploy-jboss-eap.yml -e 'target=rh72'  -t start_eap
```

##### Deploying WAR(s)/JAR(s)
```bash
ansible-playbook deploy-jboss-eap.yml -e 'target=rh72'  -e "{ 'jboss_eap_war_files': [ '/mnt/nfs/ansible/billing-hub/ojdbc7.jar' ]}" -t install_war_file
```

Structure
---------
- jboss-common role creates and configures jbossiap user, group and home directory for the JBoss instance.

- `defaults/main.yml` centralize the default variables that could be overridden
- `tasks/main.yml` coordinate the execution of the different tasks
- `tasks/00__prereqs.yml` Create users and groups and ensure zip installation archive is present
- `tasks/01__graceful_removal.yml` Stop any existing server with same configuration and remove its files
- `tasks/02__copy_and_unpack.yml` Create directory for the installation, unpack it
- `tasks/03__configure.yml` Configure the installation via configuration templates and set up management users
- `tasks/04__register_service.yml` register the instance as a linux service and start it (`systemctl start jboss_{{ instance.name }}`)
