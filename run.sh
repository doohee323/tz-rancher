#!/bin/bash

#set -x

exit 0

vagrant snapshot list

vagrant snapshot save rancher rancher_init --force
vagrant snapshot save node node_init --force

vagrant snapshot save rancher rancher_latest --force
vagrant snapshot save rancher rancher_longhorn --force

vagrant snapshot restore rancher rancher_init
vagrant snapshot restore node node_init

vagrant snapshot restore rancher rancher_latest
vagrant snapshot restore rancher rancher_longhorn
