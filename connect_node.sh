#!/bin/bash

#USAGE: ./reconnect <project-name-as-in-hil> <node-name-as-in-hil> <iscsi-server-ip-address>
node_list="$(hil list_project_nodes $1)"

if [[ $node_list =~ (^|[[:space:]])"$2"($|[[:space:]]) ]] ; then
  sudo su << EOF
  cp /usr/lib/python2.7/site-packages/ims-0.3-py2.7.egg/ims/ipxe.temp /var/lib/tftpboot/$2.ipxe
  chmod 755 /var/lib/tftpboot/$2.ipxe
  sed -i 's/${iscsi_ip}/'"$3"'/g' /var/lib/tftpboot/$2.ipxe
  ISCSITARGET=`bmi db ls | grep "$1" | grep "$2" | awk '{print $8}'`
  sed -i 's/${target_name}/'"$ISCSITARGET"'/g' /var/lib/tftpboot/$2.ipxe
EOF
fi
