# Kumo leasing instructions

* There are 16 dell nodes available to be leased. Each node has 2 nics, em1 and em2.

* The nodes are avaiable for short term leases of 6 hours, please talk to an admin
if you want more time.

* Nodes **will be** automatically powered down and taken away from your project once the lease expires.

* For provisioning, we connect `em1` to the bmi provisioning network natively (happens automatically)

* If you require a public IP address for your node, email kumo@lists.massopen.cloud

## Using HIL

HIL allows users to reserve nodes and connect them via isolated networks.

1. Logon to the kumo-hil-client (available over Internet).
  `ssh username@kumo-hil.massopen.cloud` (Helpful tips about SSH available in the last section of this document)

2. Export your HIL credentials that an admin should have given you. In bash, do this

```
export HIL_USERNAME=username
export HIL_PASSWORD=password
export HIL_ENDPOINT='http://192.168.100.210:80'
```

You could put these in your bashrc so they are automatically in your environment
when you login (you could figure out it's equivalent if you are using a different shell).

3. Basic HIL commands:

* `hil list_project_nodes <project-name>`
    This will list all the nodes that are currently added to your project.

* `hil list_nodes free`
   will list all nodes that are available.

* `hil project_connect_node <project-name> <node-name>`.
    This will add the node to your project.

* `hil project_detach_node <project-name> <node-name>`.
    This will remove the node from your project. Before running this command, make
    sure that you remove all networks first.

* `hil show_node <node-name>`
    This will show you the information about your node.

* `hil node_connect_network <node-name> <nic-name> <network-name> <channel>`
    to connect your node's nic to a network. Channel could either be `vlan/native`
    or `vlan/<vlan-id>`.

* to find the vlan-id of a network, run `hil show_network <network-name>`

* `hil node_detach_network <node-name> <nic-name> <network-name>`
    this will remove <network-name> from your node's nic.

* `hil node_power_cycle <node-name>`.
    to power cycle a node.

* `hil node_power_off <node-name>`.
    to power off a node.

For more information about HIL, checkout the [HIL Repo](github.com/cci-moc/hil)


## Using BMI

BMI allows you to provision software on your nodes. Once your nodes are reserved using HIL
you can use BMI to pxe boot your node.

Note: BMI uses diskless provisioing, so your changes are not saved to the local disk. Your disk is
saved in ceph that BMI automatically manages.

1. Logon to the BMI machine via HIL client.
    `ssh username@kumo-bmi-no-seccloud.infra.massopen.cloud`
    or use its ip address which is 192.168.100.142

2. Once logged in, export your HIL credentials explained above. In addition to that
set the BMI_CONFIG variable. In bash, do this:
    `export BMI_CONFIG=/etc/bmi/bmiconfig.cfg`

Test that bmi works by running `bmi db ls` command.


3. Run this command to see a list of available images. The project name is the same name as in HIL.
    `bmi ls <project-name>`


4. If this is the first time you got a node, and you want to provision it with an OS using BMI.
Run this command:
    `bmi provision <project-name> <node-name> <image-name> bmi-provision-net-no-seccloud em1`


    * Here bmi-provision-net-no-seccloud is the name of the provisioning network,
    and em1 is the name of the nic. You could change it if you know what you are doing.

    * Make sure that the network `bmi-provision-net-no-seccloud` is not already connected.
    If it is, then disconnect that network using HIL and then run the BMI command again.

    * The command should return `success` within 5-10 seconds.


If you had already provisioned a node using bmi, and just want to re-reserve your node then
do the following:

* put the node in your project using HIL.
`hil project_connect_node <project-name> <node-name>`

* connect `em1` of your node to the bmi provisioning network.
`hil node_connect_network <node-name> em1 bmi-provision-net-no-seccloud vlan/native`

* run this script available in your path.

 `connect_node.sh <project-name> <node-name>`


This command will only work if you already had that node provisioned using bmi.


5. Once you provision your node, power cycle your node using HIL and it should boot
into your image in 3-4 minutes.

For dell-XX node, the ip address is 10.10.10.1XX
eg; dell-4 = 10.10.10.104, dell=12 = 10.10.10.112

You can now ssh to your nodes using those IP addresses.


6. To deprovision a node, run this:
    `bmi dpro <project-name> <node-name> bmi-provision-net-no-seccloud em1`

    * Make sure that the network bmi-provision-net-no-seccloud is connected to the node
    you are trying to deprovision. If not, attach is natively using HIL.

    * This command should return `success` within 5-10 seconds. This will **delete** your
    image.

For more information about BMI, checkout the [BMI repo](github.com/cci-moc/ims)


## How to SSH

This section can be skipped if you already know how to ssh like a pro.

This is intented to simplify ssh for linux users. Windows user can use putty to ssh.

* Create a `config` file in your `.ssh` directory, and edit & paste the following:

```
Host kumo
    User <username>
    Hostname kumo-hil.massopen.cloud
    ForwardAgent yes

Host kumobmi
    User <username>
    Hostname 192.168.100.142
    ProxyCommand ssh kumo -W %h:%p
```

* Make sure you have ssh agent forwarding on.
  Run `ssh-add -l` to see list of available identities, if it doesn't display anything
  then run `ssh-add -k` it will print "Identity added: /path/to/key"

* Now from a local terminal, type `ssh kumo` to get to the kumo-hil-client.

* From another local terminal, type `ssh kumobmi` to get to kumo-bmi machine.

## How to connect your nodes to internet

1. Connect any of your nics to the `internet` network either natively or as a
tagged network. Recommended way to do is to connect em2 to `internet` natively.

2. Determine the mac address of the nic you have connected by running
`hil show_node <node-name>` which will print the names and mac addresses of all
NICs.

3. Run `ip a` on your node which will list out all the available interfaces and
their mac addresses. Interface `em2` in HIL is called `em2` in RHEL7 images, and
`eth12` in CentOS6 images. Though this may change in other images.

4. Create a network configuration file in `/etc/sysconfig/network-scripts/`.
Change the DEVICE to the name of your NIC.
```
DEVICE=em2
BOOTPROTO=dhcp
ONBOOT=yes
DEFROUTE=yes
```
and save it as ifcfg-em2 (basically, ifcfg-<interface-name>).

then run `ifup em2` and your interface should get the network configuration from a
DHCP server and you should have access to internet.

If you connect to the internet network as tagged, then follow these
[instructions](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/sec-configure_802_1q_vlan_tagging_using_the_command_line) to configure your
interface.




