# Kumo leasing instructions

* There are 16 dell nodes available to be leased. Each node has 2 nics, em1 and em2.

* The nodes are avaiable for short term leases of 6 hours, please talk to an admin
if you want more time.

* Nodes **will be** automatically powered down and taken away from your project once the lease expires.

* For provisioning, we connect `em1` to the bmi provisioning network natively.

* To connect your node to internet, connect any of your nics to the `internet` network
either natively or as a tagged network. Making it tagged would require you to
do some additional configuration on your node. Recommended way to do is to connect em2 to `internet` natively.
If you know what you are doing, you can ignore this section.

* If you require a public IP address for your node, talk to Naved/Rado.

## Using HIL

1. Logon to the kumo-hil-client (available over Internet).
  `ssh username@kumo-hil.massopen.cloud`

2. Export your HIL credentials that an admin should have given you.

```
export HIL_USERNAME=username
export HIL_PASSWORD=password
export HIL_ENDPOINT='http://192.168.100.210:80'
```

You could put these in your bashrc so they are automatically in your environment
when you login.

3. Basic HIL commands:

* `hil list_project_nodes <project-name>`
    This will list all the nodes that your project has access to.

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


## Using BMI

1. Logon to the BMI machine (available only through the HIL client).
    `ssh username@kumo-bmi-no-seccloud.infra.massopen.cloud`
    or use it's ip address which is 192.168.100.142

2. Once logged in, export your HIL credentials explained above. In addition to that
do this:
    `export BMI_CONFIG=/etc/bmi/bmiconfig.cfg`

Test bmi works by running `bmi db ls` command.


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


If you had already provisioned a node using bmi, and just want to reconnect your image
to your node, run this script available in your path.
reconnect.sh <project-name> <node-name>

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


## How to SSH

This is intented for linux users. Windows user can use putty to ssh.

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
