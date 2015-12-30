#!/bin/sh

set -e

IFACE=${1:-eth2}
CLUSTER_TOKEN=${2}
TARGET=${3:-"/etc/etcd2-environment"}

IP=`ifconfig $IFACE | grep -m 1 inet | awk '{print $2}'`
URL="http://${IP}"

echo "Creating ${TARGET} file with etcd2 configuration to be available on ${IP} address"

touch ${TARGET}

echo "ETCD_DISCOVERY=https://discovery.etcd.io/${CLUSTER_TOKEN}" > ${TARGET}
echo "ETCD_ADVERTISE_CLIENT_URLS=${URL}:2379" >> ${TARGET}
echo "ETCD_INITIAL_ADVERTISE_PEER_URLS=${URL}:2380" >> ${TARGET}
echo "ETCD_LISTEN_CLIENT_URLS=${URL}:2379,${URL}:4001,http://127.0.0.1:2379,http://127.0.0.1:4001" >> ${TARGET}
echo "ETCD_LISTEN_PEER_URLS=${URL}:2380" >> ${TARGET}
