#!/bin/bash

#set -x

exit 0

vagrant snapshot list

vagrant snapshot save rancher rancher_init --force
vagrant snapshot save node node_init --force

vagrant snapshot restore rancher rancher_init
vagrant snapshot restore node node_init --force
